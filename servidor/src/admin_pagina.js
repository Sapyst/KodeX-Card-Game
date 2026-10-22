// Página do painel (servida em /admin). HTML/CSS/JS num só arquivo; conversa com /admin/api/* usando a senha guardada
// só neste navegador (localStorage).
export const PAGINA_ADMIN = String.raw`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex"><title>KodeX Admin</title>
<style>
:root{--fundo:#0f0b13;--painel:#1c1520;--borda:#3a2c36;--ouro:#e2b85a;--ouro2:#ffe39a;--creme:#f2e6c8;--apagado:#a89a8e;--verde:#7fcf8a;--vermelho:#ff8a7a;--azul:#9ad0ff}
*{box-sizing:border-box}body{margin:0;background:var(--fundo);color:var(--creme);font:14px/1.45 system-ui,sans-serif}
header{display:flex;align-items:center;gap:12px;padding:12px 16px;border-bottom:1px solid var(--borda);background:#150f19;position:sticky;top:0;z-index:2}
header h1{font-size:18px;margin:0;color:var(--ouro2);letter-spacing:.06em}header nav{display:flex;gap:6px;margin-left:auto}
button,input,textarea,select{font:inherit;color:var(--creme);background:#241a28;border:1px solid var(--borda);border-radius:6px;padding:7px 10px}
button{cursor:pointer}button.principal{background:#4a3214;border-color:var(--ouro);color:var(--ouro2)}button:hover{filter:brightness(1.2)}
button.aba.ativa{border-color:var(--ouro);color:var(--ouro2)}main{max-width:1100px;margin:0 auto;padding:16px}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;margin-bottom:16px}
.card{background:var(--painel);border:1px solid var(--borda);border-radius:8px;padding:10px 12px}.card b{display:block;font-size:22px;color:var(--ouro2)}
.card span{color:var(--apagado);font-size:12px}table{width:100%;border-collapse:collapse;background:var(--painel);border-radius:8px;overflow:hidden}
th,td{padding:7px 9px;border-bottom:1px solid var(--borda);text-align:left}th{color:var(--apagado);font-weight:500;font-size:12px}
tr.linha:hover{background:#2a1f30;cursor:pointer}.duas{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.25fr);gap:14px}.form input,.form textarea{width:100%;min-width:0}
@media(max-width:800px){.duas{grid-template-columns:1fr}header{flex-wrap:wrap}}
.caixa{background:var(--painel);border:1px solid var(--borda);border-radius:8px;padding:12px 14px;margin-bottom:14px}
.caixa h2{margin:0 0 8px;font-size:15px;color:var(--ouro)}.kv{display:grid;grid-template-columns:auto 1fr;gap:3px 12px}.kv span{color:var(--apagado)}
.form{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}.form label{font-size:12px;color:var(--apagado);display:flex;flex-direction:column;gap:3px}
.form .cheia{grid-column:1/-1}textarea{min-height:70px;resize:vertical}.atalhos{display:flex;flex-wrap:wrap;gap:6px;margin:6px 0 10px}
.ok{color:var(--verde)}.erro{color:var(--vermelho)}.apagado{color:var(--apagado)}pre{white-space:pre-wrap;font-size:12px;background:#120d15;padding:8px;border-radius:6px;max-height:260px;overflow:auto}
.etiqueta{display:inline-block;padding:1px 7px;border-radius:9px;font-size:11px;border:1px solid var(--borda);margin:1px}
#entrar{max-width:360px;margin:12vh auto;text-align:center}#entrar input{width:100%;margin:10px 0}
</style></head><body>
<div id="entrar" hidden><h1 style="color:var(--ouro2)">KodeX Admin</h1><p class="apagado">Senha do painel (fica só neste navegador).</p>
<input id="senha" type="password" autocomplete="current-password"><button class="principal" onclick="entrar()">Entrar</button><p id="msgEntrar" class="erro"></p></div>
<div id="app" hidden>
<header><h1>KODEX ADMIN</h1><nav><button class="aba ativa" data-aba="contas" onclick="aba('contas')">Contas</button>
<button class="aba" data-aba="erros" onclick="aba('erros')">Erros</button><button onclick="sair()">Sair</button></nav></header>
<main>
<div class="cards" id="resumo"></div>
<section id="tela-contas">
 <div style="display:flex;gap:8px;margin-bottom:10px"><input id="busca" placeholder="Buscar por nome, Kode ou código (6 letras)" style="flex:1" onkeydown="if(event.key==='Enter')buscar()"><button onclick="buscar()">Buscar</button></div>
 <div class="duas"><div><table><thead><tr><th>Nome</th><th>Código</th><th>Nível</th><th>Moedas</th><th>Visto</th></tr></thead><tbody id="lista"></tbody></table></div>
 <div id="detalhe"><div class="caixa apagado">Escolha uma conta na lista.</div></div></div>
</section>
<section id="tela-erros" hidden><div id="erros"></div></section>
</main></div>
<datalist id="cartasLista"></datalist>
<script>
const $=(s)=>document.querySelector(s);let SENHA=localStorage.getItem("kodex_admin")||"";let atual=null;
const esc=(s)=>String(s??"").replace(/[&<>"']/g,(c)=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const quando=(t)=>{if(!t)return"-";const d=Math.floor(Date.now()/1000)-t;if(d<120)return"agora";if(d<3600)return Math.floor(d/60)+" min";if(d<86400)return Math.floor(d/3600)+" h";return Math.floor(d/86400)+" dias"};
async function api(rota,corpo){const r=await fetch("/admin/api/"+rota,{method:corpo?"POST":"GET",headers:{authorization:"Admin "+SENHA,"content-type":"application/json"},body:corpo?JSON.stringify(corpo):undefined});
 const j=await r.json().catch(()=>({ok:false,erro:"resposta inválida"}));if(r.status===401){sair(true);throw new Error("senha")}return j}
async function entrar(){SENHA=$("#senha").value.trim();try{const r=await api("resumo");if(r.ok){localStorage.setItem("kodex_admin",SENHA);iniciar()}}catch(e){$("#msgEntrar").textContent="Senha errada."}}
function sair(errada){localStorage.removeItem("kodex_admin");SENHA="";$("#app").hidden=true;$("#entrar").hidden=false;if(errada)$("#msgEntrar").textContent="Senha errada ou expirada."}
function aba(a){document.querySelectorAll(".aba").forEach(b=>b.classList.toggle("ativa",b.dataset.aba===a));$("#tela-contas").hidden=a!=="contas";$("#tela-erros").hidden=a!=="erros";if(a==="erros")carregarErros()}
async function iniciar(){$("#entrar").hidden=true;$("#app").hidden=false;carregarResumo();buscar();
 const c=await api("cartas");$("#cartasLista").innerHTML=(c.cartas||[]).map(x=>'<option value="'+esc(x)+'">').join("")}
async function carregarResumo(){const r=await api("resumo");const it=[["contas","contas"],["ativas_24h","ativas em 24 h"],["ativas_7d","ativas em 7 dias"],["jogando_agora","online jogando agora"],["na_fila","buscando partida"],["partidas_24h","partidas online 24 h"],["com_kode","com Kode"],["erros_7d","erros em 7 dias"]];
 $("#resumo").innerHTML=it.map(([k,t])=>'<div class="card"><b>'+(r[k]??0)+'</b><span>'+t+'</span></div>').join("")}
async function buscar(){const r=await api("contas?q="+encodeURIComponent($("#busca").value));
 $("#lista").innerHTML=(r.contas||[]).map(c=>'<tr class="linha" onclick="abrir(\''+c.id+'\')"><td>'+esc(c.nome||"(sem nome)")+(c.kode?' <span class="etiqueta">'+esc(c.kode)+'</span>':'')+'</td><td>'+c.curto+'</td><td>'+c.nivel+'</td><td>'+c.moedas+'</td><td class="apagado">'+quando(c.visto)+'</td></tr>').join("")||'<tr><td colspan="5" class="apagado">Nada encontrado.</td></tr>'}
async function abrir(id){atual=id;const r=await api("conta/"+id);if(!r.ok){$("#detalhe").innerHTML='<div class="caixa erro">'+esc(r.erro)+'</div>';return}const p=r.perfil;
 const est=p.estat.contra||{};const lin=(o)=>o?((o.v|0)+"V "+(o.d|0)+"D "+(o.e|0)+"E"):"-";
 $("#detalhe").innerHTML='<div class="caixa"><h2>'+esc(p.nome||"(sem nome)")+' <span class="apagado">· '+r.curto+'</span></h2><div class="kv">'+
 '<span>Kode</span><div>'+esc(r.kode||"-")+'</div><span>Email</span><div>'+esc(r.email||"-")+'</div><span>Criada</span><div>'+quando(r.criado)+' atrás</div>'+
 '<span>Nível</span><div>'+p.nivel+' ('+p.xp+' XP) · '+p.conquistas+' conquistas · título: '+esc(p.titulo||"-")+'</div>'+
 '<span>Moedas · Koins</span><div>'+p.moedas+' · '+p.koins+'</div><span>Essência · Boosters</span><div>'+p.essencia+' · '+p.boosters+'</div>'+
 '<span>Coleção</span><div>'+p.cartas_distintas+' diferentes ('+p.cartas_total+' cartas) · '+p.foils+' foils · '+p.versos+' versos</div>'+
 '<span>Dias seguidos</span><div>'+p.dias_seguidos+' (máx. '+p.dias_max+')</div><span>Contra IA</span><div>'+lin(est.ia)+'</div><span>Contra gente</span><div>'+lin(est.jogador)+'</div><span>Contra bot</span><div>'+lin(est.bot)+'</div>'+
 '<span>Modos</span><div>'+(p.torneio_vencido?'<span class="etiqueta">Torneio</span>':'')+(p.choronzon_vencido?'<span class="etiqueta">Choronzon</span>':'')+'<span class="etiqueta">'+p.enigmas+' enigmas</span></div>'+
 '<span>Títulos</span><div>'+(p.titulos.map(t=>'<span class="etiqueta">'+esc(t)+'</span>').join("")||"-")+'</div></div></div>'+
 '<div class="caixa"><h2>Dar presente com mensagem</h2><div class="atalhos"><button onclick="atalho(100,0,0,0,\'Sentimos muito pelo problema. Aqui vai uma ajuda!\')">Consolo: 100 moedas</button>'+
 '<button onclick="atalho(0,50,0,1,\'Um empurrãozinho para a sua jornada no Códice!\')">Boost: 1 booster + 50 Koins</button><button onclick="atalho(0,0,200,0,\'Para você criar a carta que falta.\')">200 Essência</button></div>'+
 '<div class="form"><label>Moedas<input id="g_m" type="number" min="0" value="0"></label><label>Koins<input id="g_k" type="number" min="0" value="0"></label>'+
 '<label>Essência<input id="g_e" type="number" min="0" value="0"></label><label>Boosters<input id="g_b" type="number" min="0" value="0"></label>'+
 '<label class="cheia">Cartas (ids separados por vírgula)<input id="g_c" list="cartasLista" placeholder="ex.: alt_babalon, ind_tupa"></label>'+
 '<label class="cheia">Mensagem (a pessoa lê no jogo)<textarea id="g_msg" maxlength="400"></textarea></label><label>Assinado<input id="g_de" value="KodeX"></label>'+
 '<div class="cheia"><button class="principal" onclick="presente()">Enviar presente</button> <span id="g_res"></span></div></div></div>'+
 '<div class="caixa"><h2>Correio enviado</h2>'+((p.correio||[]).slice().reverse().map(c=>'<div style="margin-bottom:6px">'+quando(c.ts)+' atrás · '+(c.lido?'<span class="ok">lida</span>':'<span class="apagado">não lida</span>')+'<br>'+esc(c.msg)+'</div>').join("")||'<span class="apagado">Nenhum.</span>')+'</div>'+
 '<div class="caixa"><h2>Últimas partidas</h2>'+((p.historico||[]).map(h=>'<div>'+quando(h.t)+' · '+esc(h.modo)+' · '+esc(h.adversario)+' · <b>'+esc(h.resultado)+'</b> · '+h.turnos+' turnos</div>').join("")||'<span class="apagado">Nenhuma.</span>')+'</div>'}
function atalho(m,k,e,b,msg){$("#g_m").value=m;$("#g_k").value=k;$("#g_e").value=e;$("#g_b").value=b;$("#g_msg").value=msg}
async function presente(){const corpo={moedas:+$("#g_m").value,koins:+$("#g_k").value,essencia:+$("#g_e").value,boosters:+$("#g_b").value,
 cartas:$("#g_c").value.split(",").map(s=>s.trim()).filter(Boolean),mensagem:$("#g_msg").value,de:$("#g_de").value};
 if(!confirm("Enviar este presente?"))return;const r=await api("conta/"+atual+"/presente",corpo);
 if(r.ok){$("#g_res").innerHTML='<span class="ok">Enviado! A pessoa vê ao abrir o jogo.</span>';setTimeout(()=>abrir(atual),900)}else $("#g_res").innerHTML='<span class="erro">'+esc(r.erro)+'</span>'}
async function carregarErros(){const r=await api("erros");$("#erros").innerHTML=(r.erros||[]).map(e=>'<div class="caixa"><h2>'+esc(e.nome||"(sem nome)")+' · '+e.curto+' <span class="apagado">· '+quando(e.ts)+' atrás · v'+esc(e.versao)+' · '+esc(e.so)+'</span></h2><pre>'+esc(e.texto)+'</pre></div>').join("")||'<div class="caixa apagado">Nenhum relatório de erro.</div>'}
if(SENHA)iniciar().catch(()=>sair());else{$("#entrar").hidden=false}
</script></body></html>`;
