# Lü Dongbin

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 2 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Suas outras Entidades têm +1 ATK.

## Contexto mitológico
Lü Dongbin (呂洞賓, nome pessoal Lü Yan), o mais popular dos Oito Imortais, é um letrado Tang de túnica de erudito e espada mata-demônios às costas. Sua conversão é o "Sonho do Painço Amarelo": numa pousada de Handan, enquanto Zhongli Quan cozinha painço, Lü adormece e vive uma vida inteira — exames, altos cargos, casamento, filhos, desgraça, exílio, morte. Acorda e o painço ainda não ficou pronto. Compreende que a carreira mundana é sonho e segue o mestre, que o submete a dez provas (dar fortuna, ser caluniado, enfrentar demônios) antes de ensinar a alquimia.

A espada, que ele recebe do Imortal do Dragão de Fogo, corta paixões e demônios — mas a lenda mais contada é a da espada que falha: Lü a lança voando contra o mestre chan Huanglong, ela não o alcança, e Lü aprende humildade e se torna discípulo ("a espada voadora contra Huanglong"). Aparece três vezes, não reconhecido, na Torre de Yueyang, sobre o Lago Dongting ("três vezes bêbado em Yueyang, e ninguém o conhece"). O motivo do painço vem do *Zhenzhong ji* (Shen Jiji, Tang), onde o sonhador ainda é um certo Lu Sheng e o taoista um "Velho Lü"; a peça Yuan *Huangliang meng* de Ma Zhiyuan transfere o sonho para Lü Dongbin e faz de Zhongli o mestre. Outras fontes: *Dongyou Ji*; *Chunyang dijun shenhua miaotong ji* (Miao Shanshi, Yuan). A escola Quanzhen o venera como patriarca ("Imperador Chunyang"); é padroeiro de barbeiros, letrados e fabricantes de tinta de escrever.

Na carta é o líder que faz os outros valerem mais: a aura de +1 ATK nos companheiros é o que torna uma fileira de 1/2 uma ameaça.

## Papel no jogo
Centro da sinergia dos Oito Imortais. Com três outros corpos em campo a aura vale +3 ATK total por turno de ataque. Deve ser protegido (Cao Guojiu, Guan Yu com Guarda; Pêssego da Imortalidade para voltar à mão). O oponente que o silencia ou o mata primeiro desarma o deck — por isso ele é fraco sozinho e forte atrás de uma linha.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 2 + aura +1 ATK nas outras aliadas (3, §10) = 7. Dentro.

## Dados
```json
{
  "id": "tao_lu_dongbin",
  "nome": "Lü Dongbin",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "static", "acoes": [ { "op": "buff", "alvo": "other_ally_entities", "atk": 1, "vida": 0, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, elegant scholar, hanfu, scholar robe, scholar cap, mustache, goatee, sword on back, demon-slaying sword, holding horsetail whisk, fly whisk, calm commanding stance, radiant aura, wind in robes, standing on cloud, mountain lake below, pavilion, pine trees, distant peaks, jade green and vermilion, mist, ink wash feel, golden rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: espada mata-demônios nas costas · espanador de crina na mão · túnica e chapéu de letrado · bigode e cavanhaque · sobre nuvem
```krea
An elegant adult Chinese scholar about 40 years old, realistic proportions, calm commanding face with a thin mustache and a goatee. He wears a pale blue scholar robe with wide sleeves and a black soft scholar cap. A long straight demon-slaying sword in a dark scabbard is strapped across his back, the hilt over his right shoulder. His right hand holds a horsetail fly whisk with white hair; his left hand is raised in a calm gesture. He has two normal arms and two hands. He stands firmly on a small cloud above a mountain lake with a pavilion, robes moving in the wind, lit by a golden rim of light.
```
