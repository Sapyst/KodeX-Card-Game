// Página do painel (servida em /admin). HTML/CSS/JS num só arquivo; conversa com /admin/api/* usando a senha guardada
// só neste navegador (localStorage). Abas: Contas (busca + filtros), Alertas (comportamento alarmante), Registro (tudo
// o que o painel fez) e Erros (relatórios enviados pelos jogadores).
export const PAGINA_ADMIN = String.raw`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex"><title>KodeX Admin</title>
<style>
:root{--fundo:#0f0b13;--painel:#1c1520;--borda:#3a2c36;--ouro:#e2b85a;--ouro2:#ffe39a;--creme:#f2e6c8;--apagado:#a89a8e;--verde:#7fcf8a;--vermelho:#ff8a7a;--azul:#9ad0ff;--roxo:#c8a0ff}
*{box-sizing:border-box}body{margin:0;background:var(--fundo);color:var(--creme);font:14px/1.45 system-ui,sans-serif}
header{display:flex;align-items:center;gap:12px;padding:12px 16px;border-bottom:1px solid var(--borda);background:#150f19;position:sticky;top:0;z-index:2;flex-wrap:wrap}
header h1{font-size:18px;margin:0;color:var(--ouro2);letter-spacing:.06em}header nav{display:flex;gap:6px;margin-left:auto;flex-wrap:wrap}
button,input,textarea,select{font:inherit;color:var(--creme);background:#241a28;border:1px solid var(--borda);border-radius:6px;padding:7px 10px}
button{cursor:pointer}button.principal{background:#4a3214;border-color:var(--ouro);color:var(--ouro2)}button.perigo{background:#4a1418;border-color:#a03030;color:#ffb0a0}
button:hover{filter:brightness(1.2)}button.aba.ativa{border-color:var(--ouro);color:var(--ouro2)}main{max-width:1200px;margin:0 auto;padding:16px}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;margin-bottom:16px}
.card{background:var(--painel);border:1px solid var(--borda);border-radius:8px;padding:10px 12px}.card b{display:block;font-size:22px;color:var(--ouro2)}
.card span{color:var(--apagado);font-size:12px}table{width:100%;border-collapse:collapse;background:var(--painel);border-radius:8px;overflow:hidden}
th,td{padding:7px 9px;border-bottom:1px solid var(--borda);text-align:left}th{color:var(--apagado);font-weight:500;font-size:12px}
tr.linha:hover{background:#2a1f30;cursor:pointer}.duas{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.25fr);gap:14px}
@media(max-width:900px){.duas{grid-template-columns:1fr}}
.caixa{background:var(--painel);border:1px solid var(--borda);border-radius:8px;padding:12px 14px;margin-bottom:14px}
.caixa h2{margin:0 0 8px;font-size:15px;color:var(--ouro)}.kv{display:grid;grid-template-columns:auto 1fr;gap:3px 12px}.kv span{color:var(--apagado)}
.form{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px}.form label{font-size:12px;color:var(--apagado);display:flex;flex-direction:column;gap:3px}
.form input,.form textarea,.form select{width:100%;min-width:0}.form .cheia{grid-column:1/-1}textarea{min-height:60px;resize:vertical}
.filtros{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:10px;align-items:center}.filtros label{font-size:12px;color:var(--apagado)}
.atalhos{display:flex;flex-wrap:wrap;gap:6px;margin:6px 0 10px}.ok{color:var(--verde)}.erro{color:var(--vermelho)}.apagado{color:var(--apagado)}
pre{white-space:pre-wrap;font-size:12px;background:#120d15;padding:8px;border-radius:6px;max-height:260px;overflow:auto}
.etq{display:inline-block;padding:1px 7px;border-radius:9px;font-size:11px;border:1px solid var(--borda);margin:1px}
.ban-soft{border-color:#c0902a;color:#ffd080}.ban-shadow{border-color:#7a5aa8;color:var(--roxo)}.ban-hard{border-color:#a03030;color:#ffb0a0}
.alerta{border-color:#a03030;color:#ffb0a0}.res-v{color:var(--verde);font-weight:600}.res-d{color:var(--vermelho);font-weight:600}.res-e{color:var(--apagado);font-weight:600}#entrar{max-width:360px;margin:12vh auto;text-align:center}#entrar input{width:100%;margin:10px 0}
.sinal{display:flex;gap:8px;padding:3px 0;border-bottom:1px dashed var(--borda)}.peso{min-width:22px;text-align:center;border-radius:5px;background:#3a1a1e;color:#ffb0a0;font-size:12px}
</style></head><body>
<div id="entrar" hidden><h1 style="color:var(--ouro2)">KodeX Admin</h1><p class="apagado">Senha do painel (fica só neste navegador).</p>
<input id="senha" type="password" autocomplete="current-password" onkeydown="if(event.key==='Enter')entrar()"><button class="principal" onclick="entrar()">Entrar</button><p id="msgEntrar" class="erro"></p></div>
<div id="app" hidden>
<header><h1>KODEX ADMIN</h1><nav>
<button class="aba ativa" data-aba="contas" onclick="aba('contas')">Contas</button><button class="aba" data-aba="alertas" onclick="aba('alertas')">Alertas</button>
<button class="aba" data-aba="registro" onclick="aba('registro')">Registro</button><button class="aba" data-aba="erros" onclick="aba('erros')">Erros</button>
<button onclick="sair()">Sair</button></nav></header>
<main>
<div class="cards" id="resumo"></div>
<section id="tela-contas">
 <div class="filtros"><input id="busca" placeholder="Nome, Kode ou código (6 letras)" style="flex:1;min-width:200px" onkeydown="if(event.key==='Enter')buscar()">
 <label>Atividade <select id="f_at" onchange="buscar()"><option value="">todas</option><option value="24h">últimas 24 h</option><option value="7d">últimos 7 dias</option><option value="inativa">sumidas há 30+ dias</option></select></label>
 <label>Ban <select id="f_ban" onchange="buscar()"><option value="">todas</option><option value="nenhum">sem ban</option><option value="qualquer">qualquer ban</option><option value="soft">soft</option><option value="shadow">shadow</option><option value="hard">hard</option></select></label>
 <label>Nível ≥ <input id="f_nv" type="number" min="0" style="width:70px" onchange="buscar()"></label><label>Moedas ≥ <input id="f_m" type="number" min="0" style="width:90px" onchange="buscar()"></label>
 <label><input id="f_al" type="checkbox" onchange="buscar()"> com alerta</label><label><input id="f_kode" type="checkbox" onchange="buscar()"> com Kode</label>
 <label><input id="f_email" type="checkbox" onchange="buscar()"> com email</label><button onclick="buscar()">Buscar</button></div>
 <div class="duas"><div><table><thead><tr><th>Nome</th><th>Código</th><th>Nv</th><th>Moedas</th><th>Visto</th></tr></thead><tbody id="lista"></tbody></table></div>
 <div id="detalhe"><div class="caixa apagado">Escolha uma conta na lista.</div></div></div>
</section>
<section id="tela-alertas" hidden><div class="filtros"><span class="apagado">Contas com sinais nos últimos 7 dias que ainda não foram revisadas. O jogador não vê nada disto.</span>
 <button onclick="varrer()" style="margin-left:auto">Rodar a varredura agora</button></div><div id="alertas"></div></section>
<section id="tela-registro" hidden><div id="registro"></div></section>
<section id="tela-erros" hidden><div id="erros"></div></section>
</main></div>
<datalist id="cartasLista"></datalist>
<script>
const $=(s)=>document.querySelector(s);let SENHA=localStorage.getItem("kodex_admin")||"";let atual=null;let PAPEL="";let atualKode="";
// entrada pelo site (kodex.sapyst.workers.dev/login): a senha chega no fragmento #k=… (não vai ao servidor) e some da barra
if(location.hash.startsWith("#k=")){SENHA=decodeURIComponent(location.hash.slice(3));history.replaceState(null,"",location.pathname);localStorage.setItem("kodex_admin",SENHA)}
const esc=(s)=>String(s??"").replace(/[&<>"']/g,(c)=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const quando=(t)=>{if(!t)return"-";const d=Math.floor(Date.now()/1000)-t;if(d<0){const f=-d;return"em "+(f<86400?Math.ceil(f/3600)+" h":Math.ceil(f/86400)+" dias")}if(d<120)return"agora";if(d<3600)return Math.floor(d/60)+" min";if(d<86400)return Math.floor(d/3600)+" h";return Math.floor(d/86400)+" dias"};
const data=(t)=>t?new Date(t*1000).toLocaleString("pt-BR"):"-";
const resultado=(r)=>{const t=String(r||"").replace("vitoria","vitória");const c=/vit/.test(t)?"res-v":/der/.test(t)?"res-d":"res-e";return'<span class="'+c+'">'+esc(t||"-")+'</span>'};
const banEtq=(b)=>b?'<span class="etq ban-'+b+'">'+b+'</span>':'';
async function api(rota,corpo){const r=await fetch("/admin/api/"+rota,{method:corpo?"POST":"GET",headers:{authorization:"Admin "+SENHA,"content-type":"application/json"},body:corpo?JSON.stringify(corpo):undefined});
 const j=await r.json().catch(()=>({ok:false,erro:"resposta inválida"}));if(r.status===401){sair(true);throw new Error("senha")}return j}
async function entrar(){SENHA=$("#senha").value.trim();try{const r=await api("resumo");if(r.ok){localStorage.setItem("kodex_admin",SENHA);iniciar()}}catch(e){$("#msgEntrar").textContent="Senha errada."}}
function sair(errada){localStorage.removeItem("kodex_admin");SENHA="";$("#app").hidden=true;$("#entrar").hidden=false;if(errada)$("#msgEntrar").textContent="Senha errada ou expirada."}
function aba(a){document.querySelectorAll(".aba").forEach(b=>b.classList.toggle("ativa",b.dataset.aba===a));["contas","alertas","registro","erros"].forEach(x=>$("#tela-"+x).hidden=x!==a);
 if(a==="alertas")carregarAlertas();if(a==="registro")carregarRegistro();if(a==="erros")carregarErros()}
async function iniciar(){$("#entrar").hidden=true;$("#app").hidden=false;carregarResumo();buscar();
 const c=await api("cartas");$("#cartasLista").innerHTML=(c.cartas||[]).map(x=>'<option value="'+esc(x)+'">').join("")}
async function carregarResumo(){const r=await api("resumo");PAPEL=r.papel||"";document.title="KodeX "+(PAPEL==="mod"?"Moderação":"Admin");const it=[["contas","contas"],["ativas_24h","ativas em 24 h"],["ativas_7d","ativas em 7 dias"],["jogando_agora","online jogando agora"],["na_fila","buscando partida"],["partidas_24h","partidas online 24 h"],["alertas","contas com alerta"],["punidas","contas punidas"],["erros_7d","erros em 7 dias"]];
 $("#resumo").innerHTML=it.map(([k,t])=>'<div class="card"><b>'+(r[k]??0)+'</b><span>'+t+'</span></div>').join("")}
async function buscar(){const q=new URLSearchParams({q:$("#busca").value,atividade:$("#f_at").value,ban:$("#f_ban").value,nivel_min:$("#f_nv").value||0,moedas_min:$("#f_m").value||0,
 alerta:$("#f_al").checked?1:"",kode:$("#f_kode").checked?1:"",email:$("#f_email").checked?1:""});const r=await api("contas?"+q);
 $("#lista").innerHTML=(r.contas||[]).map(c=>'<tr class="linha" onclick="abrir(\''+c.id+'\')"><td>'+esc(c.nome||"(sem nome)")+(c.kode?' <span class="etq">'+esc(c.kode)+'</span>':'')+banEtq(c.ban)+(c.alerta?' <span class="etq alerta">alerta '+c.alerta+'</span>':'')+'</td><td>'+c.curto+'</td><td>'+c.nivel+'</td><td>'+c.moedas+'</td><td class="apagado">'+quando(c.visto)+'</td></tr>').join("")||'<tr><td colspan="5" class="apagado">Nada encontrado.</td></tr>'}
async function abrir(id){atual=id;aba("contas");const r=await api("conta/"+id);if(!r.ok){$("#detalhe").innerHTML='<div class="caixa erro">'+esc(r.erro)+'</div>';return}const p=r.perfil;atualKode=r.kode||"";
 const est=p.estat.contra||{};const lin=(o)=>o?((o.v|0)+"V "+(o.d|0)+"D "+(o.e|0)+"E"):"-";const pun=r.punicao;
 $("#detalhe").innerHTML='<div class="caixa"><h2>'+esc(p.nome||"(sem nome)")+' <span class="apagado">· '+r.curto+'</span> '+(pun?banEtq(pun.tipo):'')+(r.alerta?' <span class="etq alerta">alerta '+r.alerta+'</span>':'')+'</h2><div class="kv">'+
 '<span>Kode</span><div>'+esc(r.kode||"-")+'</div><span>Email</span><div>'+esc(r.email||"-")+'</div><span>Criada</span><div>'+data(r.criado)+'</div>'+
 '<span>Nível</span><div>'+p.nivel+' ('+p.xp+' XP) · '+p.conquistas+' conquistas · título: '+esc(p.titulo||"-")+'</div>'+
 '<span>Moedas · Koins</span><div>'+p.moedas+' · '+p.koins+'</div><span>Essência · Boosters</span><div>'+p.essencia+' · '+p.boosters+'</div>'+
 '<span>Coleção</span><div>'+p.cartas_distintas+' diferentes ('+p.cartas_total+' cartas) · '+p.foils+' foils · '+p.versos+' versos</div>'+
 '<span>Dias seguidos</span><div>'+p.dias_seguidos+' (máx. '+p.dias_max+')</div><span>Contra IA</span><div>'+lin(est.ia)+'</div><span>Contra gente</span><div>'+lin(est.jogador)+'</div><span>Contra bot</span><div>'+lin(est.bot)+'</div>'+
 '<span>Modos</span><div>'+(p.torneio_vencido?'<span class="etq">Torneio</span>':'')+(p.choronzon_vencido?'<span class="etq">Choronzon</span>':'')+'<span class="etq">'+p.enigmas+' enigmas</span></div>'+
 '<span>Títulos</span><div>'+(p.titulos.map(t=>'<span class="etq">'+esc(t)+'</span>').join("")||"-")+'</div></div></div>'+
 // Kode (suporte)
 (r.kode?'<div class="caixa"><h2>Kode · '+esc(r.kode)+'</h2><p class="apagado" style="margin-top:0">Resetar a chave: a frase secreta antiga deixa de valer e o jogo pede 12 palavras novas no próximo acesso.'+(PAPEL==="admin"?' Com senha temporária: também troca a senha por uma sorteada (para mandar por email como suporte); o jogo obriga a escolher outra e os aparelhos abertos saem da conta.':'')+'</p>'+
 '<button onclick="kodeReset(false)">Resetar chave do Kode</button> '+(PAPEL==="admin"?'<button class="perigo" onclick="kodeReset(true)">Resetar chave + senha temporária</button>':'')+'<div id="k_res" style="margin-top:10px"></div></div>':
 '<div class="caixa"><h2>Kode</h2><p class="apagado" style="margin-top:0">Esta conta ainda não tem Kode: joga como convidado, com o progresso só no aparelho. Os botões de reset da chave e da senha funcionam quando a pessoa criar um Kode (Opções &gt; Sincronizar conta).</p>'+
 '<button disabled style="opacity:.45;cursor:not-allowed">Resetar chave do Kode</button> '+(PAPEL==="admin"?'<button class="perigo" disabled style="opacity:.45;cursor:not-allowed">Resetar chave + senha temporária</button>':'')+'</div>')+
 // punição
 '<div class="caixa"><h2>Punição</h2>'+(pun?'<p>'+banEtq(pun.tipo)+' '+(pun.tipo==="hard"?"para sempre":(pun.ate?"até "+data(pun.ate)+" ("+quando(pun.ate)+")":"até tirar"))+'<br><span class="apagado">Motivo:</span> '+esc(pun.motivo)+'</p><button onclick="perdoar()">Tirar a punição</button>':'<p class="apagado">Nenhuma.</p>')+
 '<div class="form" style="margin-top:10px"><label>Tipo<select id="p_tipo"><option value="soft">Soft-ban (por tempo)</option><option value="shadow">Shadow-ban (linha de baixo)</option><option value="hard">Hard-ban (para sempre)</option></select></label>'+
 '<label>Dias<input id="p_dias" type="number" min="0" step="0.5" value="3"></label><label class="cheia">Motivo (fica no registro; no soft/hard a pessoa vê)<input id="p_motivo" maxlength="300"></label>'+
 '<div class="cheia apagado" style="font-size:12px">Soft: não entra no jogo online até a data. Shadow: joga normal, mas a busca só junta com outros shadow-banidos e bots (sem dias = até tirar). Hard: bloqueado para sempre.</div>'+
 '<div class="cheia"><button class="perigo" onclick="punir()">Aplicar punição</button> <span id="p_res"></span></div></div></div>'+
 // sinais e revisão
 '<div class="caixa"><h2>Sinais de comportamento</h2>'+((r.sinais||[]).map(s=>'<div class="sinal"><span class="peso">'+s.peso+'</span><span>'+esc(s.descricao)+' <span class="apagado">· '+esc(s.detalhe)+' · '+quando(s.ts)+'</span></span></div>').join("")||'<span class="apagado">Nenhum.</span>')+
 '<p class="apagado">Revisada: '+(r.revisado?data(r.revisado):"nunca")+'</p><button onclick="revisado()">Marcar como revisada</button></div>'+
 // notas
 '<div class="caixa"><h2>Notas da moderação</h2>'+((r.notas||[]).map(n=>'<div style="margin-bottom:6px"><span class="apagado">'+data(n.ts)+'</span><br>'+esc(n.texto)+'</div>').join("")||'<span class="apagado">Nenhuma.</span>')+
 '<div class="form" style="margin-top:8px"><label class="cheia"><textarea id="n_txt" placeholder="Anotação (só a moderação vê)"></textarea></label><div class="cheia"><button onclick="nota()">Salvar nota</button></div></div></div>'+
 // presente
 '<div class="caixa"><h2>Dar presente com mensagem</h2><div class="atalhos"><button onclick="atalho(100,0,0,0,\'Sentimos muito pelo problema. Aqui vai uma ajuda!\')">Consolo: 100 moedas</button>'+
 '<button onclick="atalho(0,50,0,1,\'Um empurrãozinho para a sua jornada no Códice!\')">Boost: 1 booster + 50 Koins</button><button onclick="atalho(0,0,200,0,\'Para você criar a carta que falta.\')">200 Essência</button></div>'+
 '<div class="form"><label>Moedas<input id="g_m" type="number" min="0" value="0"></label><label>Koins<input id="g_k" type="number" min="0" value="0"></label>'+
 '<label>Essência<input id="g_e" type="number" min="0" value="0"></label><label>Boosters<input id="g_b" type="number" min="0" value="0"></label>'+
 '<label class="cheia">Cartas (ids separados por vírgula)<input id="g_c" list="cartasLista" placeholder="ex.: alt_babalon, ind_tupa"></label>'+
 '<label class="cheia">Mensagem (a pessoa lê no jogo)<textarea id="g_msg" maxlength="400"></textarea></label><label>Assinado<input id="g_de" value="KodeX"></label>'+
 '<div class="cheia"><button class="principal" onclick="presente()">Enviar presente</button> <span id="g_res"></span></div></div></div>'+
 '<div class="caixa"><h2>Correio enviado</h2>'+((p.correio||[]).slice().reverse().map(c=>'<div style="margin-bottom:6px">'+quando(c.ts)+' atrás · '+(c.lido?'<span class="ok">lida</span>':'<span class="apagado">não lida</span>')+'<br>'+esc(c.msg)+'</div>').join("")||'<span class="apagado">Nenhum.</span>')+'</div>'+
 '<div class="caixa"><h2>Últimas partidas</h2>'+((p.historico||[]).map(h=>'<div>'+quando(h.t)+' · '+esc(h.modo)+' · '+esc(h.adversario)+' · '+resultado(h.resultado)+' · '+h.turnos+' turnos</div>').join("")||'<span class="apagado">Nenhuma.</span>')+
 '<h2 style="margin-top:10px">Online</h2>'+((r.online||[]).map(o=>'<div>'+quando(o.quando)+' · contra '+esc(o.contra)+' · '+esc(o.estado)+' · '+resultado(o.resultado)+'</div>').join("")||'<span class="apagado">Nenhuma.</span>')+'</div>'}
// mesma derivação do jogo (nuvem.gd reforcar): SHA-256 encadeado 200 mil vezes sobre "kodex|usuário|senha"
async function reforcar(t){let b=new TextEncoder().encode(t);for(let i=0;i<200000;i++)b=new Uint8Array(await crypto.subtle.digest("SHA-256",b));return[...b].map(x=>x.toString(16).padStart(2,"0")).join("")}
function senhaAleatoria(){const a="abcdefghjkmnpqrstuvwxyz23456789",v=crypto.getRandomValues(new Uint8Array(10));return[...v].map(x=>a[x%a.length]).join("")}
const MODELO={pt:(u,s)=>"Olá! Aqui é o suporte do KodeX.\n\nRedefinimos o acesso do seu Kode \""+u+"\".\nSenha temporária: "+s+"\n\nAbra o jogo, vá em Opções > Sincronizar conta > Entrar com Kode e use essa senha. O jogo vai pedir uma senha nova e gerar 12 palavras novas: guarde-as em um lugar seguro.\n\nNinguém do KodeX vai pedir a sua senha ou as suas palavras.",
 en:(u,s)=>"Hi! This is KodeX support.\n\nWe reset access to your Kode \""+u+"\".\nTemporary password: "+s+"\n\nOpen the game, go to Options > Sync account > Sign in with Kode and use this password. The game will ask for a new password and create 12 new words: keep them somewhere safe.\n\nNo one from KodeX will ever ask for your password or your words.",
 es:(u,s)=>"¡Hola! Te escribe el soporte de KodeX.\n\nRestablecimos el acceso a tu Kode \""+u+"\".\nContraseña temporal: "+s+"\n\nAbre el juego, ve a Opciones > Sincronizar cuenta > Entrar con Kode y usa esta contraseña. El juego te pedirá una contraseña nueva y creará 12 palabras nuevas: guárdalas en un lugar seguro.\n\nNadie de KodeX te pedirá tu contraseña ni tus palabras."};
async function kodeReset(comSenha){const u=atualKode;if(!u)return;
 if(!confirm(comSenha?"Resetar a chave E trocar a senha do Kode \""+u+"\" por uma temporária?\nOs aparelhos abertos saem da conta.":"Resetar a chave do Kode \""+u+"\"?\nA frase antiga deixa de valer."))return;
 const res=$("#k_res");let corpo={senha:false},senha="";
 if(comSenha){senha=senhaAleatoria();res.innerHTML='<span class="apagado">Gerando a senha (reforço de 200 mil rodadas, alguns segundos)...</span>';corpo={senha:true,chave_senha:await reforcar("kodex|"+u+"|"+senha)}}
 const r=await api("conta/"+atual+"/kode_reset",corpo);if(!r.ok){res.innerHTML='<span class="erro">'+esc(r.erro)+'</span>';return}
 if(!comSenha){res.innerHTML='<span class="ok">Chave resetada. O jogo pede 12 palavras novas no próximo acesso.</span>';return}
 res.innerHTML='<p class="ok" style="margin:0 0 6px">Senha temporária (aparece só agora):</p><div style="display:flex;gap:6px;align-items:center"><code id="k_senha" style="font-size:18px;color:var(--ouro2);background:#120d15;padding:6px 10px;border-radius:6px">'+esc(senha)+'</code><button onclick="navigator.clipboard.writeText($(\'#k_senha\').textContent)">Copiar senha</button></div>'+
  '<p class="apagado" style="margin:10px 0 4px">Email pronto para mandar: <select id="k_lang" onchange="$(\'#k_email\').value=MODELO[this.value](\''+esc(u)+'\',\''+senha+'\')"><option value="pt">Português</option><option value="en">English</option><option value="es">Español</option></select> <button onclick="navigator.clipboard.writeText($(\'#k_email\').value)">Copiar email</button></p>'+
  '<textarea id="k_email" style="width:100%;min-height:170px">'+esc(MODELO.pt(u,senha))+'</textarea>'}
function atalho(m,k,e,b,msg){$("#g_m").value=m;$("#g_k").value=k;$("#g_e").value=e;$("#g_b").value=b;$("#g_msg").value=msg}
async function presente(){const corpo={moedas:+$("#g_m").value,koins:+$("#g_k").value,essencia:+$("#g_e").value,boosters:+$("#g_b").value,
 cartas:$("#g_c").value.split(",").map(s=>s.trim()).filter(Boolean),mensagem:$("#g_msg").value,de:$("#g_de").value};
 if(!confirm("Enviar este presente?"))return;const r=await api("conta/"+atual+"/presente",corpo);
 if(r.ok){$("#g_res").innerHTML='<span class="ok">Enviado! A pessoa vê ao abrir o jogo.</span>';setTimeout(()=>abrir(atual),900)}else $("#g_res").innerHTML='<span class="erro">'+esc(r.erro)+'</span>'}
async function punir(){const tipo=$("#p_tipo").value,dias=+$("#p_dias").value,motivo=$("#p_motivo").value.trim();
 const txt={soft:"Soft-ban por "+dias+" dias",shadow:"Shadow-ban"+(dias?" por "+dias+" dias":" até tirar"),hard:"HARD-BAN PARA SEMPRE"}[tipo];
 if(!confirm(txt+"?\nMotivo: "+motivo))return;const r=await api("conta/"+atual+"/punir",{tipo,dias,motivo});
 if(r.ok){abrir(atual);buscar();carregarResumo()}else $("#p_res").innerHTML='<span class="erro">'+esc(r.erro)+'</span>'}
async function perdoar(){const motivo=prompt("Por que tirar a punição? (fica no registro)")||"";const r=await api("conta/"+atual+"/perdoar",{motivo});if(r.ok){abrir(atual);buscar();carregarResumo()}}
async function nota(){const texto=$("#n_txt").value.trim();if(!texto)return;const r=await api("conta/"+atual+"/nota",{texto});if(r.ok)abrir(atual)}
async function revisado(){const r=await api("conta/"+atual+"/revisado",{});if(r.ok){abrir(atual);carregarResumo()}}
async function carregarAlertas(){const r=await api("alertas");$("#alertas").innerHTML=(r.alertas||[]).map(a=>'<div class="caixa" style="cursor:pointer" onclick="abrir(\''+a.id+'\')"><h2>'+esc(a.nome||"(sem nome)")+' <span class="apagado">· '+a.curto+'</span> <span class="etq alerta">'+a.pts+' pontos</span> '+banEtq(a.ban)+' <span class="apagado" style="font-size:12px">último sinal '+quando(a.ult)+' atrás</span></h2>'+
 a.tipos.map(t=>'<div class="sinal"><span class="peso">'+t.pts+'</span><span>'+esc(t.descricao)+' <span class="apagado">× '+t.n+'</span></span></div>').join("")+'</div>').join("")||'<div class="caixa apagado">Nenhum alerta pendente.</div>'}
async function varrer(){const r=await api("varrer",{});alert("Varredura: "+r.olhadas+" contas olhadas, "+r.sinais+" sinais novos.");carregarAlertas();carregarResumo()}
async function carregarRegistro(){const r=await api("registro");$("#registro").innerHTML='<table><thead><tr><th>Quando</th><th>Ação</th><th>Conta</th><th>Detalhe</th></tr></thead><tbody>'+
 ((r.registro||[]).map(x=>'<tr'+(x.alvo?' class="linha" onclick="abrir(\''+x.alvo+'\')"':'')+'><td class="apagado">'+data(x.ts)+'</td><td>'+esc(x.acao)+'</td><td>'+(x.alvo?esc(x.nome||"(sem nome)")+' · '+x.curto:"-")+'</td><td style="font-size:12px">'+esc(x.detalhe)+'</td></tr>').join("")||'<tr><td colspan="4" class="apagado">Nada ainda.</td></tr>')+'</tbody></table>'}
async function carregarErros(){const r=await api("erros");$("#erros").innerHTML=(r.erros||[]).map(e=>'<div class="caixa"><h2>'+esc(e.nome||"(sem nome)")+' · '+e.curto+' <span class="apagado">· '+quando(e.ts)+' atrás · v'+esc(e.versao)+' · '+esc(e.so)+'</span></h2><pre>'+esc(e.texto)+'</pre></div>').join("")||'<div class="caixa apagado">Nenhum relatório de erro.</div>'}
if(SENHA)iniciar().catch(()=>sair());else{$("#entrar").hidden=false}
</script></body></html>`;
