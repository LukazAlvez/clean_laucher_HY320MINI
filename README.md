# 📽️ Projeto: Otimização Extrema & DarkLauncher para Projetor HY320 Mini (Android 12)

Este repositório documenta todo o processo de engenharia reversa, backup em baixo nível, otimização extrema de desempenho e desenvolvimento de um **Launcher Nativo em Kotlin (Clean & Dark)** para o projetor **HY320 Mini** (SoC Rockchip RK3326, Android 12).

---

## 📋 Sumário
1. [Especificações de Hardware e Sistema](#-especificações-de-hardware-e-sistema)
2. [Diagnóstico Inicial e Problemas Encontrados](#-diagnóstico-inicial-e-problemas-encontrados)
3. [Backup Completo Bit a Bit das Partições (Raw eMMC)](#-backup-completo-bit-a-bit-das-partições)
4. [Otimização do Sistema e Debloat Seguro](#-otimização-do-sistema-e-debloat-seguro)
5. [Desenvolvimento do DarkLauncher (Kotlin Nativo)](#-desenvolvimento-do-darklauncher)
6. [Substituição Definitiva do Launcher Original](#-substituição-definitiva-do-launcher-original)
7. [Compilação Nativa AOT (Speed) via dex2oat](#-compilação-nativa-aot-speed)
8. [Instalação e Configuração do Stremio TV](#-instalação-e-configuração-do-stremio-tv)
9. [Comparativo Real de Desempenho (Antes vs Depois)](#-comparativo-real-de-desempenho)
10. [Como Reverter as Alterações](#-como-reverter-as-alterações)

---

## 🔬 Especificações de Hardware e Sistema

- **Dispositivo**: Projetor HY320 Mini
- **SoC**: Rockchip RK3326 (`rk3326_sgo`) — Quad-core ARM Cortex-A35
- **Arquitetura**: 32-bit (`armeabi-v7a`)
- **Memória RAM**: 1 GB (966 MB utilizáveis)
- **Armazenamento**: Samsung eMMC 8 GB (7.456 MB)
- **Resolução de Renderização**: 1280x720 (Density: 240 dpi)
- **Sistema Operacional**: Android 12 (API 32, Build `SQ3A.220705.003.A1 userdebug`)
- **Conectividade**: Wi-Fi 2.4/5GHz, Bluetooth 5.0

---

## ⚠️ Diagnóstico Inicial e Problemas Encontrados

No estado de fábrica, o projetor apresentava sérios gargalos:
1. **Memória RAM Esgotada**: Restavam apenas **15 MB de RAM livre**, com 951 MB ocupados pelo sistema e bloatwares.
2. **Uso Agressivo de ZRAM**: O aparelho utilizava ~127 MB de ZRAM comprimida, gerando uso constante de CPU e microtravamentos na interface.
3. **Bloatware e Telemetria Ativa**:
   - `com.shzhtxcz.txbox.launcher` (Launcher padrão com serviços de anúncios embutidos: `com.speed.adv.AdService`, `com.media.systemadsolution`).
   - `com.shzhtxcz.txbox` (Serviços de log e registro em segundo plano: `LogService`, `RegisterService`).
   - Aplicativos chineses inúteis: `com.sszztxr.app` (AppStore paralela), `com.oranth.accessibility` (desktop OEM), `com.android.rockchip.camera2` (câmera em hardware sem sensor).
4. **Modo JIT Lento**: Todos os aplicativos rodavam no modo interpretado `verify`, exigindo tradução de instruções em tempo real pela fraca CPU Cortex-A35.

---

## 💾 Backup Completo Bit a Bit das Partições

Antes de qualquer alteração destrutiva, todas as partições do armazenamento eMMC foram extraídas diretamente via bloco raw (`/dev/block/by-name/*`):

| Partição | Tamanho | Função |
| :--- | :---: | :--- |
| `super.img` | 2,4 GB | Sistema operacional completo (Android 12 system, vendor, product, odm) |
| `recovery.img` | 108 MB | Ambiente de recuperação de fábrica |
| `boot.img` | 40 MB | Kernel Linux e ramdisk de inicialização |
| `backup.img` | 372 MB | Imagem de restauração de fábrica |
| `baseparameter.img` | 1 MB | **Calibração de Keystone óptico e perfil de tela LCD** |
| `cust.img` | 64 MB | Customizações de fábrica |
| `dtbo.img` | 4 MB | Device Tree Overlay |
| `logo.img` | 64 MB | Telas de boot inicial |
| `metadata.img` | 16 MB | Metadados de encriptação e partições dinâmicas |
| `misc.img` | 4 MB | Controle de boot e recovery flag |
| `security.img` | 4 MB | Chaves de segurança |
| `trust.img` | 4 MB | ARM Trusted Firmware / OP-TEE |
| `uboot.img` | 4 MB | Bootloader U-Boot |
| `vbmeta.img` | 1 MB | Android Verified Boot metadata |

> 📁 Arquivos armazenados com segurança em `backup_hy320_mini/`.

---

## 🧹 Otimização do Sistema e Debloat Seguro

O debloat foi feito utilizando desativação segura em nível de usuário (`pm disable-user --user 0`), preservando a integridade das partições somente-leitura.

### Pacotes Desativados:
```bash
# Telemetria, anúncios e testes de fábrica
pm disable-user --user 0 com.shzhtxcz.txbox
pm disable-user --user 0 com.sszztxr.app
pm disable-user --user 0 com.oranth.accessibility
pm disable-user --user 0 com.aispeech.tvui
pm disable-user --user 0 com.huawei.qx
pm disable-user --user 0 com.rockchip.itvbox
pm disable-user --user 0 com.android.mgstv
pm disable-user --user 0 com.shzhtxcz.txcz.test
pm disable-user --user 0 com.rockchip.devicetest
pm disable-user --user 0 com.bozee.usbdisplay
pm disable-user --user 0 com.sszztxr.oott

# Apps redundantes sem hardware correspondente
pm disable-user --user 0 com.android.rockchip.camera2
pm disable-user --user 0 com.android.cellbroadcastreceiver
pm disable-user --user 0 com.android.cellbroadcastservice
```

### Otimizações Globais:
- Redução de escala de animações:
  - `settings put global window_animation_scale 0.5`
  - `settings put global transition_animation_scale 0.5`
  - `settings put global animator_duration_scale 0.5`
- Desativação de varredura contínua de Bluetooth em segundo plano:
  - `settings put global ble_scan_always_enabled 0`

---

## 🎨 Desenvolvimento do DarkLauncher

Criado um launcher minimalista em **Kotlin puro**, sem dependências externas, anúncios ou rastreadores:

### Características:
- **Preto Absoluto (`#000000`)**: Bloqueia 100% da luz do projetor LCD nos pixels pretos, aumentando o contraste óptico na parede.
- **D-Pad First**: Foco visual claro (borda branca de alto contraste + escala 1.08x) em qualquer elemento selecionado pelo controle remoto.
- **Estrutura Compacta (Enquadramento 720p Nativo)**:
  - Topo: Relógio digital em caixa grande (fonte leve) + Data em português + Saudação ("Bom dia" / "Boa noite").
  - Meio: Fileira horizontal de **Favoritos** organizáveis com o botão OK.
  - Base: 3 pílulas rápidas (`Aplicativos`, `Play Store`, `Configurações`).
- **Gaveta de Aplicativos**: Grade limpa exibindo estritamente os 5 apps funcionais instalados.
- **Consumo de Memória**: Apenas **33 MB** de PSS (contra ~120 MB do original).

---

## 🔄 Substituição Definitiva do Launcher Original

1. Backup preventivo do APK de fábrica: `com.shzhtxcz.txbox.launcher.apk` (10,8 MB).
2. Registro do DarkLauncher como padrão:
   ```bash
   cmd package set-home-activity com.antigravity.darklauncher/.MainActivity
   ```
3. Desativação do launcher de fábrica:
   ```bash
   pm disable-user --user 0 com.shzhtxcz.txbox.launcher
   ```
4. Ao pressionar o botão **HOME** no controle remoto, o projetor abre o DarkLauncher instantaneamente.

---

## ⚡ Compilação Nativa AOT (Speed)

Para eliminar o atraso do compilador JIT em tempo real na CPU RK3326, os principais aplicativos foram compilados para código de máquina ARM Ahead-Of-Time:

```bash
cmd package compile -m speed -f com.antigravity.darklauncher
cmd package compile -m speed -f com.google.android.youtube.tv
cmd package compile -m speed -f com.netflix.mediaclient
cmd package compile -m speed -f com.android.vending
cmd package compile -m speed -f com.android.systemui
cmd package compile -m speed -f com.stremio.one
```

**Resultado**: Todos os pacotes promovidos para `[status=speed]`. O YouTube TV passou a inicializar a frio em **1,29 segundos**.

---

## 🎬 Instalação e Configuração do Stremio TV

- **Pacote Instalado**: `com.stremio.one` v1.10.4 oficial para Android TV (32-bit ARM).
- **Compilado com perfil `speed`** e fixado na primeira posição dos favoritos.
- **Add-ons Brasileiros Instalados Diretamente**:
  - ❄️ **FrostStream (v2.2.9)**: Filmes e séries com múltiplos provedores rápidos (CloutDB, RedeFlix, MegaEmbed).
  - 🦅 **FenixFlix (v1.2.8)**: Filmes, séries, animes e novelas dubladas em HD/4K PT-BR.
  - ⚽ **Meu Futebol (v1.0.1)**: Transmissões de esportes e futebol ao vivo.
  - 🎬 **BestCine (v13.0.0)**: Filmes e canais de TV ao vivo em servidores dedicados.

---

## 📊 Comparativo Real de Desempenho

| Métrica | Original de Fábrica | Pós-Otimização + DarkLauncher | Ganho Real |
| :--- | :---: | :---: | :---: |
| **Memória RAM Livre** | **15 MB** | **406 MB** | **+2.600% de RAM livre** |
| **RAM Usada pelo Launcher** | ~120 MB | **33 MB** | **-72% de memória** |
| **Abertura a Frio do Launcher** | 1,60 s | **0,75 s** | **Mais de 2x mais rápido** |
| **Apps de Bloatware Ativos** | 14 processos | **0 processos** | 100% Limpo |
| **Abertura do YouTube TV** | Lenta com travamentos | **1,29 s** | Instantâneo |
| **Contraste na Projeção** | Cinza escuro | **Preto Absoluto (#000000)** | Alto contraste |

---

## ⏪ Como Reverter as Alterações

Todos os scripts para desfecho ou restauração estão prontos:

- **Reativar o Launcher de Fábrica**:
  ```bash
  adb shell pm enable com.shzhtxcz.txbox.launcher
  adb shell cmd package set-home-activity com.shzhtxcz.txbox.launcher/com.shzhtxcz.txbox.SplashActivity
  ```
- **Reativar os Serviços Residuais**: Executar `reverter_ajustes_2_e_3.bat`
- **Reverter todo o Debloat**: Executar `reverter_otimizacoes.bat`
