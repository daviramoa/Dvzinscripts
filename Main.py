# bot_return_business.py
import discord
from discord import app_commands
from discord.ext import commands
from discord.ui import View, Select, Button, Modal, TextInput
import json
import os
import io
import qrcode
import binascii
import asyncio
from typing import Optional, List


# ================= CONFIGURAÇÃO =================
CANAL_LOGS_ID = 123456789012345678  # substitua pelo ID do canal onde logs de compra vão
DATA_PRODUTOS = "produto_returnbusiness.json"
DATA_CUPONS = "cupons_returnbusiness.json"
DATA_PEDIDOS = "pedidos_returnbusiness.json"  # opcional: histórico de pedidos
PIX_CHAVE_PADRAO = ""  # Se quiser chave fixa da loja, coloque aqui (opcional)
STORE_NAME = "ERIN BOTS"
# =================================================

# Verifica token
if not TOKEN:
    raise RuntimeError("Variável de ambiente DISCORD_TOKEN não encontrada. Defina antes de executar o bot.")

# ===== INTENTS =====
intents = discord.Intents.default()
intents.message_content = True
intents.guilds = True
intents.members = True

bot = commands.Bot(command_prefix="!", intents=intents)
# Usaremos bot.tree (app_commands) para registrar slash commands

# ===== Helpers JSON =====
def garantir_arquivo(arquivo: str, valor_padrao):
    if not os.path.exists(arquivo):
        with open(arquivo, "w", encoding="utf-8") as f:
            json.dump(valor_padrao, f, ensure_ascii=False, indent=4)

def carregar_json(arquivo: str, padrao):
    garantir_arquivo(arquivo, padrao)
    with open(arquivo, "r", encoding="utf-8") as f:
        return json.load(f)

def salvar_json(arquivo: str, dados):
    with open(arquivo, "w", encoding="utf-8") as f:
        json.dump(dados, f, ensure_ascii=False, indent=4)

def listar_produtos() -> List[dict]:
    return carregar_json(DATA_PRODUTOS, [])

def listar_cupons() -> List[dict]:
    return carregar_json(DATA_CUPONS, [])

def adicionar_produto_json(prod):
    dados = listar_produtos()
    dados.append(prod)
    salvar_json(DATA_PRODUTOS, dados)

def adicionar_cupom_json(cup):
    dados = listar_cupons()
    dados.append(cup)
    salvar_json(DATA_CUPONS, dados)

def registrar_pedido(pedido: dict):
    garantir_arquivo(DATA_PEDIDOS, [])
    dados = carregar_json(DATA_PEDIDOS, [])
    dados.append(pedido)
    salvar_json(DATA_PEDIDOS, dados)

# ===== BR CODE / PIX =====
def tlv(tag: str, value: str) -> str:
    length = f"{len(value):02d}"
    return f"{tag}{length}{value}"

def crc16_ccitt(data: bytes, init: int = 0xFFFF) -> int:
    return binascii.crc_hqx(data, init)

def generate_pix_brcode(key: str, amount: float, merchant_name: str = STORE_NAME, merchant_city: str = "BRASIL", txid: str = "***") -> str:
    payload = ""
    payload += tlv("00", "01")
    payload += tlv("01", "12")
    mai = ""
    mai += tlv("00", "br.gov.bcb.pix")
    mai += tlv("01", key)
    payload += tlv("26", mai)
    payload += tlv("52", "0000")
    payload += tlv("53", "986")
    payload += tlv("54", f"{amount:.2f}")
    payload += tlv("58", "BR")
    payload += tlv("59", merchant_name[:25])
    payload += tlv("60", merchant_city[:15])
    payload += tlv("62", tlv("05", txid[:25]))
    payload_for_crc = payload + "63" + "04"
    crc = crc16_ccitt(payload_for_crc.encode("utf-8"))
    brcode = payload_for_crc + f"{crc:04X}"
    return brcode

def gerar_qrcode_img_bytes(codigo_pix: str) -> io.BytesIO:
    qr = qrcode.QRCode(version=1, box_size=8, border=2)
    qr.add_data(codigo_pix)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return buf

# ===== MODALS (estilo) =====
class ModalNovoProduto(Modal):
    def __init__(self):
        super().__init__(title="✨ Cadastrar Produto — RETURN BUSINESS")
        self.nome = TextInput(label="Nome do produto", max_length=80)
        self.descricao = TextInput(label="Descrição (opcional)", style=discord.TextStyle.long, required=False)
        self.preco = TextInput(label="Preço (ex: 19.90)")
        self.chave = TextInput(label="Chave PIX (email/telefone/EVP)", required=True)
        self.add_item(self.nome)
        self.add_item(self.descricao)
        self.add_item(self.preco)
        self.add_item(self.chave)

    async def on_submit(self, interaction: discord.Interaction):
        try:
            preco = float(self.preco.value.replace(",", "."))
            if preco < 0:
                raise ValueError
        except Exception:
            await interaction.response.send_message("🚫 Preço inválido. Use por exemplo `19.90`.", ephemeral=True)
            return
        produto = {
            "nome": self.nome.value.strip(),
            "descricao": (self.descricao.value or "").strip(),
            "preco": preco,
            "chave_pix": self.chave.value.strip()
        }
        adicionar_produto_json(produto)
        await interaction.response.send_message(f"✅ Produto **{produto['nome']}** cadastrado.", ephemeral=True)

class ModalNovoCupom(Modal):
    def __init__(self):
        super().__init__(title="🏷️ Criar Cupom — RETURN BUSINESS")
        self.codigo = TextInput(label="Código do cupom (ex: RB10)", max_length=30)
        self.desconto = TextInput(label="Desconto (%) ex: 10")
        self.add_item(self.codigo)
        self.add_item(self.desconto)

    async def on_submit(self, interaction: discord.Interaction):
        try:
            desconto = float(self.desconto.value.replace(",", "."))
            if desconto <= 0 or desconto > 100:
                raise ValueError
        except Exception:
            await interaction.response.send_message("🚫 Desconto inválido (1-100).", ephemeral=True)
            return
        cupom = {"codigo": self.codigo.value.strip().upper(), "desconto": desconto}
        adicionar_cupom_json(cupom)
        await interaction.response.send_message(f"🎉 Cupom **{cupom['codigo']}** criado ({cupom['desconto']}%).", ephemeral=True)

class ModalAplicarCupom(Modal):
    def __init__(self, carrinho):
        super().__init__(title="🏷️ Aplicar Cupom — RETURN BUSINESS")
        self.carrinho = carrinho
        self.codigo = TextInput(label="Código do cupom", max_length=30)
        self.add_item(self.codigo)

    async def on_submit(self, interaction: discord.Interaction):
        codigo = self.codigo.value.strip().upper()
        cupons = listar_cupons()
        encontrado = next((c for c in cupons if c["codigo"] == codigo), None)
        if not encontrado:
            await interaction.response.send_message("❌ Cupom não encontrado.", ephemeral=True)
            return
        self.carrinho.cupom = encontrado
        await self.carrinho.atualizar_mensagem()
        await interaction.response.send_message(f"✅ Cupom `{codigo}` aplicado ({encontrado['desconto']}% OFF).", ephemeral=True)

# ===== SELECT DE PRODUTOS =====
class ProdutosSelect(Select):
    def __init__(self, produtos_list, usuario_iniciador, carrinho=None):
        options = [discord.SelectOption(label=p["nome"], description=f"R$ {p['preco']:.2f}") for p in produtos_list]
        super().__init__(placeholder="🛍️ Escolha um produto...", min_values=1, max_values=1, options=options)
        self.produtos_list = produtos_list
        self.usuario_iniciador = usuario_iniciador
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        nome = self.values[0]
        produto = next((p for p in self.produtos_list if p["nome"] == nome), None)
        if produto is None:
            await interaction.response.send_message("❌ Produto não localizado.", ephemeral=True)
            return

        if self.carrinho:
            self.carrinho.add_produto(produto)
            await self.carrinho.atualizar_mensagem()
            await interaction.response.send_message(f"➕ **{produto['nome']}** adicionado ao seu carrinho.", ephemeral=True)
            return

        # cria novo canal privado para o carrinho
        guild = interaction.guild
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        safe_name = f"rb-carrinho-{interaction.user.name}".lower()[:90]
        canal = await guild.create_text_channel(safe_name, overwrites=overwrites, reason="Carrinho criado - RETURN BUSINESS")

        carrinho = CarrinhoView(owner=interaction.user, canal_notif=bot.get_channel(CANAL_LOGS_ID))
        carrinho.canal = canal
        carrinho.add_produto(produto)
        await carrinho.atualizar_mensagem()
        await interaction.response.send_message(f"🟢 Carrinho criado: {canal.mention}", ephemeral=True)

# ===== CARRINHO / VIEWS / BOTÕES =====
class CarrinhoView(View):
    def __init__(self, owner: discord.Member, canal_notif: Optional[discord.TextChannel] = None):
        super().__init__(timeout=900)  # 15 minutos
        self.owner = owner
        self.canal = None
        self.items: List[dict] = []
        self.cupom: Optional[dict] = None
        self.canal_notif = canal_notif

        # botões
        self.add_item(ButtonFinalizar(self))
        self.add_item(ButtonAdicionarMais(self, listar_produtos()))
        self.add_item(ButtonAplicarCupom(self))
        self.add_item(ButtonRemoverItem(self))
        self.add_item(ButtonCancelarCarrinho(self))

    async def interaction_check(self, interaction: discord.Interaction) -> bool:
        if interaction.user.id != self.owner.id:
            await interaction.response.send_message("❌ Somente o dono do carrinho pode usar estes botões.", ephemeral=True)
            return False
        return True

    async def on_timeout(self):
        for ch in self.children:
            ch.disabled = True
        if self.canal:
            try:
                await self.canal.send("⏳ Seu carrinho expirou — canal será fechado.", delete_after=6)
                await asyncio.sleep(2)
                await self.canal.delete()
            except Exception:
                pass

    def add_produto(self, produto: dict):
        self.items.append(produto)

    async def atualizar_mensagem(self):
        if not self.canal:
            return
        if not self.items:
            await self.canal.send("🗃️ Carrinho vazio — encerrando...", delete_after=4)
            await asyncio.sleep(1)
            try:
                await self.canal.delete()
            except Exception:
                pass
            return

        subtotal = sum(p["preco"] for p in self.items)
        total = subtotal
        desconto_txt = ""
        if self.cupom:
            desconto_valor = subtotal * (self.cupom["desconto"] / 100)
            total = subtotal - desconto_valor
            desconto_txt = f"\n🏷️ Cupom `{self.cupom['codigo']}` — -{self.cupom['desconto']}% (-R$ {desconto_valor:.2f})"

        linhas = [f"**{i+1}.** {p['nome']} — R$ {p['preco']:.2f}" for i,p in enumerate(self.items)]
        descricao = "\n".join(linhas)
        descricao += f"\n\n💰 **Subtotal:** R$ {subtotal:.2f}\n💎 **Total:** R$ {total:.2f}{desconto_txt}"

        embed = discord.Embed(title=f"🛒 {STORE_NAME} — Seu Carrinho", description=descricao, color=discord.Color.gold())
        embed.set_footer(text="Toque em Finalizar para gerar o PIX. Confirme pagamento ao enviar comprovante.")
        try:
            await self.canal.purge(limit=50)
        except Exception:
            pass
        await self.canal.send(embed=embed, view=self)

    async def gerar_e_mostrar_pix(self, interaction: discord.Interaction):
        if not self.items:
            await interaction.response.send_message("❌ Carrinho vazio.", ephemeral=True)
            return
        subtotal = sum(p["preco"] for p in self.items)
        total = subtotal
        if self.cupom:
            desconto_valor = subtotal * (self.cupom["desconto"] / 100)
            total = subtotal - desconto_valor

        chave = PIX_CHAVE_PADRAO.strip() or self.items[0].get("chave_pix")
        brcode = generate_pix_brcode(chave, total)
        qr_buf = gerar_qrcode_img_bytes(brcode)
        file = discord.File(qr_buf, filename="pix_returnbusiness.png")

        embed = discord.Embed(title="💳 PIX — RETURN BUSINESS", description=f"Total a pagar: **R$ {total:.2f}**", color=discord.Color.green())
        if self.cupom:
            embed.add_field(name="Cupom aplicado", value=f"{self.cupom['codigo']} — {self.cupom['desconto']}% OFF", inline=True)
        embed.add_field(name="Copiar e Colar (BR Code)", value=f"```{brcode}```", inline=False)
        embed.set_image(url="attachment://pix_returnbusiness.png")
        embed.set_footer(text="Depois de pagar, clique em Confirmar Pagamento ✅")

        confirm_view = View(timeout=900)
        confirm_view.add_item(ButtonConfirmarPagamento(self))
        confirm_view.add_item(ButtonCancelarCompra(self))

        try:
            await self.canal.purge(limit=50)
        except Exception:
            pass
        await self.canal.send(embed=embed, file=file, view=confirm_view)
        await interaction.response.send_message("✅ PIX enviado para o carrinho. Confirme quando efetuar o pagamento.", ephemeral=True)

# ===== BOTÕES =====
class ButtonFinalizar(Button):
    def __init__(self, carrinho):
        super().__init__(
            label="Finalizar & Gerar PIX",
            style=discord.ButtonStyle.success,
            emoji="<:pix:1429579164331020390>"
        )
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        await self.carrinho.gerar_e_mostrar_pix(interaction)

class ButtonAdicionarMais(Button):
    def __init__(self, carrinho: CarrinhoView, produtos_list):
        super().__init__(label="Adicionar mais", style=discord.ButtonStyle.primary,
                        emoji = "<:Lapis:1429587525500014682>"
        )
        self.carrinho = carrinho
        self.produtos_list = produtos_list

    async def callback(self, interaction: discord.Interaction):
        view = View(timeout=60)
        view.add_item(ProdutosSelect(self.produtos_list, usuario_iniciador=interaction.user, carrinho=self.carrinho))
        await interaction.response.send_message("🛍️ Selecione um produto para adicionar:", view=view, ephemeral=True)

class ButtonAplicarCupom(Button):
    def __init__(self, carrinho: CarrinhoView):
        super().__init__(label=" Aplicar cupom", style=discord.ButtonStyle.secondary,
                        emoji = "<:Ticket:1429591595455348869>"
                        )
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_modal(ModalAplicarCupom(self.carrinho))

class ButtonRemoverItem(Button):
    def __init__(self, carrinho: CarrinhoView):
        super().__init__(label=" Remover último", style=discord.ButtonStyle.danger, 
                        emoji = "<:Nop:1429594465538150484>"
                        )
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        if not self.carrinho.items:
            await interaction.response.send_message("⚠️ Não há itens para remover.", ephemeral=True)
            return
        removido = self.carrinho.items.pop()
        await self.carrinho.atualizar_mensagem()
        await interaction.response.send_message(f"🗑️ Removido **{removido['nome']}**", ephemeral=True)

class ButtonCancelarCarrinho(Button):
    def __init__(self, carrinho: CarrinhoView):
        super().__init__(label="❌ Cancelar carrinho", style=discord.ButtonStyle.danger)
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_message("❌ Carrinho cancelado. Canal será fechado.", ephemeral=True)
        await asyncio.sleep(1)
        try:
            await self.carrinho.canal.delete()
        except Exception:
            pass

class ButtonConfirmarPagamento(Button):
    def __init__(self, carrinho: CarrinhoView):
        super().__init__(label="✅ Confirmar Pagamento", style=discord.ButtonStyle.success)
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        subtotal = sum(p["preco"] for p in self.carrinho.items)
        total = subtotal
        if self.carrinho.cupom:
            desconto_valor = subtotal * (self.carrinho.cupom["desconto"] / 100)
            total = subtotal - desconto_valor

        # registra pedido (opcional)
        pedido = {
            "cliente_id": self.carrinho.owner.id,
            "cliente_name": str(self.carrinho.owner),
            "itens": [{"nome": p["nome"], "preco": p["preco"]} for p in self.carrinho.items],
            "total": total,
            "cupom": self.carrinho.cupom or None,
            "timestamp": discord.utils.utcnow().isoformat()
        }
        registrar_pedido(pedido)

        canal_logs = bot.get_channel(CANAL_LOGS_ID)
        produtos_text = "\n".join([f"- {p['nome']} — R$ {p['preco']:.2f}" for p in self.carrinho.items]) or "—"
        embed = discord.Embed(title="📥 Pedido Confirmado — RETURN BUSINESS", color=discord.Color.dark_gold())
        embed.add_field(name="Cliente", value=self.carrinho.owner.mention, inline=False)
        embed.add_field(name="Itens", value=produtos_text, inline=False)
        embed.add_field(name="Valor", value=f"R$ {total:.2f}", inline=False)
        if self.carrinho.cupom:
            embed.add_field(name="Cupom", value=f"{self.carrinho.cupom['codigo']} ({self.carrinho.cupom['desconto']}% OFF)", inline=False)
        embed.set_footer(text=f"Pedido registrado em {STORE_NAME}")
        if canal_logs:
            await canal_logs.send(embed=embed)
        await interaction.response.send_message("🎉 Pagamento confirmado! Obrigado pela compra — pedido registrado.", ephemeral=True)
        await asyncio.sleep(5)
        try:
            await self.carrinho.canal.delete()
        except Exception:
            pass

class ButtonCancelarCompra(Button):
    def __init__(self, carrinho: CarrinhoView):
        super().__init__(label="🚫 Cancelar compra", style=discord.ButtonStyle.danger)
        self.carrinho = carrinho

    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_message("Compra cancelada. Nenhuma notificação será enviada.", ephemeral=True)
        await asyncio.sleep(2)
        try:
            await self.carrinho.canal.delete()
        except Exception:
            pass

# ===== SLASH COMMANDS (app_commands) =====

# Helper: checa permissão de admin no guild
def is_admin(interaction: discord.Interaction) -> bool:
    return interaction.user.guild_permissions.administrator

@bot.event
async def on_ready():
    garantir_arquivo(DATA_PRODUTOS, [])
    garantir_arquivo(DATA_CUPONS, [])
    garantir_arquivo(DATA_PEDIDOS, [])
    # sincroniza comandos com o Discord
    try:
        await bot.tree.sync()
        print(f"{STORE_NAME} — Comandos slash sincronizados.")
    except Exception as e:
        print("Erro ao sincronizar comandos:", e)
    print(f"{STORE_NAME} BOT conectado como {bot.user} (ID: {bot.user.id})")

# /addproduto (admin) - abre modal
@bot.tree.command(name="addproduto", description="Cadastrar novo produto (ADM)")
async def slash_addproduto(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⚠️ Você precisa ser administrador para usar este comando.", ephemeral=True)
        return
    await interaction.response.send_modal(ModalNovoProduto())

# /addcupom (admin)
@bot.tree.command(name="addcupom", description="Criar cupom de desconto (ADM)")
async def slash_addcupom(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⚠️ Você precisa ser administrador para usar este comando.", ephemeral=True)
        return
    await interaction.response.send_modal(ModalNovoCupom())

# /vitrine (abre lista de produtos para usuários)
@bot.tree.command(name="vitrine", description="Abrir a vitrine de produtos")
async def slash_vitrine(interaction: discord.Interaction):
    produtos = listar_produtos()
    if not produtos:
        await interaction.response.send_message("🛑 Não há produtos cadastrados no momento.", ephemeral=True)
        return

    view = View(timeout=None)
    select = ProdutosSelect(produtos, usuario_iniciador=interaction.user)
    view.add_item(select)

    embed = discord.Embed(title=f"🏷️ {STORE_NAME} — Vitrine", 
description="Escolha um produto no menu abaixo para iniciar a compra.", color=discord.Color.purple())
    for p in produtos:
        embed.add_field(name=f"{p['nome']} — R$ {p['preco']:.2f}", value=p.get("descricao", "—"), inline=False)

    await interaction.response.send_message(embed=embed, view=view)

# /meuscarrinhos (apenas lista pedidos do usuário)
@bot.tree.command(name="meuspedidos", description="Ver seu histórico de pedidos")
async def slash_meuspedidos(interaction: discord.Interaction):
    garantir_arquivo(DATA_PEDIDOS, [])
    pedidos = carregar_json(DATA_PEDIDOS, [])
    meus = [p for p in pedidos if p.get("cliente_id") == interaction.user.id]
    if not meus:
        await interaction.response.send_message("📦 Você ainda não tem pedidos registrados.", ephemeral=True)
        return
    desc_lines = []
    for i,p in enumerate(meus[-10:][::-1], 1):  # mostra últimos 10
        desc_lines.append(f"**{i}.** R$ {p['total']:.2f} — {p['timestamp']}")
    embed = discord.Embed(title="🧾 Seus Pedidos — RETURN BUSINESS", description="\n".join(desc_lines), color=discord.Color.blurple())
    await interaction.response.send_message(embed=embed, ephemeral=True)

# /verprodutos (admin) - lista todos produtos
@bot.tree.command(name="verprodutos", description="Listar produtos cadastrados (ADM)")
async def slash_verprodutos(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⚠️ Apenas administradores.", ephemeral=True)
        return
    produtos = listar_produtos()
    if not produtos:
        await interaction.response.send_message("🛑 Nenhum produto cadastrado.", ephemeral=True)
        return
    lines = [f"- {p['nome']} — R$ {p['preco']:.2f} (chave: {p.get('chave_pix','—')})" for p in produtos]
    embed = discord.Embed(title="🔎 Produtos cadastrados", description="\n".join(lines), color=discord.Color.green())
    await interaction.response.send_message(embed=embed, ephemeral=True)

# ===== Mensagens: responder Pong quando for mencionado =====
@bot.event
async def on_message(message: discord.Message):
    if message.author.bot:
        return
    if bot.user in message.mentions:
        try:
            await message.channel.send("Pong! 🏓")
        except Exception:
            pass
    # importante processar comandos de prefix se forem usados (não obrigatório)
    await bot.process_commands(message)

# ===== RUN =====
if __name__ == "__main__":
    bot.run("MTQwMzc5Mzg2NDc0OTM1MTAwMg.GaVGUa.URInjJq_uK0lIcfty0wGmF4MuFpGt_PfM4grOQ")
