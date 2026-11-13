# Guia do Sintonia (passo a passo, sem programação)

## Passo 1: pegar as duas chaves gratuitas

O app usa dois serviços. Cada um dá uma "chave" (um código) de graça.

**A) AudD, que reconhece a música**
1. Entre em https://dashboard.audd.io e crie uma conta (pode usar o Google).
2. No painel aparece o seu **API Token** (uma sequência de letras e números).
3. Copie e guarde. O plano grátis serve para testar.

**B) Jamendo, que fornece as músicas livres para baixar**
1. Entre em https://devportal.jamendo.com e crie uma conta.
2. Clique em **My Applications** e depois em **Add a new application**.
3. Preencha um nome (ex.: Sintonia) e um site qualquer (ex.: https://github.com).
4. Copie o **Client ID** que aparecer.

## Passo 2: gerar o app automaticamente no GitHub

Você não precisa instalar nada no computador. O GitHub monta o app para você.

1. Abra o repositório **sintonia** no GitHub.
2. Clique em **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.
3. Crie um segredo chamado `AUDD_TOKEN` e cole a chave do AudD.
4. Crie outro chamado `JAMENDO_CLIENT_ID` e cole o Client ID do Jamendo.
5. Vá na aba **Actions**, clique em **Gerar app Android** → **Run workflow** → **Run workflow**.
6. Espere uns 10 minutos até aparecer o sinal verde ✓.
7. Clique na execução e, lá embaixo, baixe **Sintonia-android** (um arquivo .zip).

## Passo 3: instalar no celular Android

1. Abra o .zip e pegue o arquivo **app-release.apk**.
2. Mande o arquivo para o celular (WhatsApp para você mesmo, Google Drive ou cabo USB).
3. No celular, toque no arquivo. Se aparecer um aviso, toque em **Configurações** e
   ative **Permitir desta fonte**. Depois toque em **Instalar**.
4. Abra o Sintonia, toque em **Ouvir** e permita o uso do microfone.

## Como usar

- **Ouvir:** toque no botão rosa perto do som. Ele escuta 8 segundos.
- **Resultado:** mostra capa, artista e letra. Se for música livre, aparece **Baixar**.
  Se for comercial, use os botões do Spotify, Deezer, YouTube Music ou Apple Music.
- **Histórico:** todas as músicas que você já identificou.
- **Minhas músicas:** as baixadas, que tocam sem internet. Use **Buscar músicas livres**
  para encontrar e baixar milhares de músicas liberadas pelos próprios artistas.

## E o iPhone?

O código já funciona no iPhone, mas a Apple só permite instalar apps gerados num
computador Mac com uma conta de desenvolvedor (US$ 99 por ano). Quando quiser, te ajudo nisso.
