<!-- MARKDOWN HEADER - styled gradient banner -->
<div align="center">

<h1>
  <img src="assets/images/loahcapa.png" alt="Loah Studio" width="120" style="border-radius:16px;"/>
  <br/>
  **Loah Stúdio**
</h1>

<picture>
  <source srcset="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" media="(prefers-color-scheme: light)">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
</picture>
&nbsp;
<a href="https://firebase.google.com/docs" target="_blank"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"></a>
&nbsp;
<a href="https://nodejs.org" target="_blank"><img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js"></a>
&nbsp;
<a href="https://developer.mozilla.org/en-US/docs/Web/HTML" target="_blank"><img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" alt="HTML5"></a>

<br/><br/>

**Uma experiência de beleza, agendamento e compras — diretamente na palma da sua mão.** 🌸

[📖 Documentação](#-documentação) •
[🚀 Começar](#-começando) •
[🏗️ Arquitetura](#️-arquitetura) •
[📸 Telas](#-telas) •
[🤝 Contribuindo](#-contribuindo)

</div>

---

## ✨ Sobre o Projeto

O **Loah Stúdio** é uma aplicação *full-stack* desenvolvida em **Flutter**, que oferece uma experiência completa para um estúdio de beleza. O app permite que clientes naveguem pelos serviços, agendem horários, façam compras e acompanhem seus pedidos — tudo integrado com **Firebase** (Auth, Firestore, Storage, Messaging) e **Cloud Functions** no backend.

> 💡 *Projeto acadêmico / portfólio — construído com foco em boas práticas de arquitetura, design material e integração com APIs reais.*

---

## 🎨 Design & Identidade Visual

O Loah Stúdio segue uma paleta sofisticada e acolhedora, inspirada no universo da estética e do cuidado pessoal:

| Token      | Cor          | Código     | Uso                         |
|------------|-------------|------------|-----------------------------|
| 🫒 **Brown**   | Marrom      | `#5A4A42`  | Textos principais, ícones   |
| 🌸 **Pink Nude** | Rosa Suave  | `#D02F80`  | Acentos, botões secundários |
| 🔥 **Pink Strong** | Rosa Forte  | `#D80970`  | Acentos destacados, CTAs    |
| 🧈 **Cream BG**  | Bege Claro  | `#F7F4F2`  | Fundo principal             |
| 🤍 **White**     | Branco      | `#FFFFFF`  | Superfícies, cartões        |

A tipografia segue o **Material Design 3**, com o tema centralizado em `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` adaptado à identidade visual do estúdio.

---

## 📸 Telas & Funcionalidades

### 🏠 Home
- **Hero Section** — banner animado e acolhedor
- **Seção Essência** — valores e diferenciais do estúdio
- **Pilares** — os pilares de atuação da marca
- **Carrossel de Galeria** — fotos do espaço e serviços
- **Produtos em Destaque** — destaques com carrossel horizontal
- **Serviços em Destaque** — cards clicáveis com informações rápidas
- **Seção de Avaliações** — depoimentos de clientes
- **Botão Flutuante WhatsApp** — atendimento direto

### 🔐 Autenticação
- **AuthGate** — roteamento inteligente baseado no estado de login
- **Login / Registo** com validação de email
- **Verificação de Email** — página dedicada com countdown
- **Recuperação de Senha** — fluxo completo via Firebase Auth
- Persistência do estado de *email verificado* no Firestore

### 📅 Agendamento
- Seleção de serviço com **calendário** e **horários disponíveis**
- Cards de agendamento com status visual
- **Editor de agendamento** (reagendar/cancelar)
- Integração com **Cloud Functions** para confirmação e lembretes automáticos (24h e 1h)

### 🛒 Compras / Carrinho
- Catálogo de produtos com grid e destaque
- Detalhes completos do produto
- **Carrinho** com resumo, quantidades e remoção
- **Checkout** com diálogo de confirmação
- **Pedidos** com stepper de status (pendente → confirmado → entregue)
- Histórico de compras

### ⭐ Favoritos
- Lista de favoritos com remoção
- Persistência no Firestore

### 👤 Perfil
- Edição de dados pessoais
- Gerenciamento de conta

### 🔔 Notificações
- Painel de notificações em tempo real
- Push notifications via **Firebase Cloud Messaging**
- Notificações por email automáticas (nodemailer)

### 🛠️ Painel Administrativo
- **Dashboard** com estatísticas
- Gestão de **produtos**, **serviços**, **agendamentos**, **clientes** e **compras**
- Configuração da **galeria** e **pilares**
- Upload de imagens e gestão de conteúdo

---

## 🏗️ Arquitetura

O projeto segue uma **arquitetura em camadas** com separação clara de responsabilidades:

```
lib/
├── main.dart                          # Ponto de entrada (Firebase init, rotas)
├── firebase_options.dart              # Configuração Firebase por plataforma
│
├── constants/                         # Constantes globais
│   ├── colors.dart                    # Paleta de cores (AppColors)
│   └── responsive.dart                # Breakpoints responsivos
│
├── model/                             # Modelos de dados (models)
│   ├── user_model.dart
│   ├── produto_model.dart
│   ├── servico_model.dart
│   ├── pedido_model.dart
│   ├── agendamento_model.dart
│   ├── carrinho_item_model.dart
│   ├── favorito_model.dart
│   ├── avaliacao_model.dart
│   ├── notificacao_model.dart
│   ├── pagamento_config_model.dart
│   ├── dashboard_stats_model.dart
│   ├── site_config_model.dart
│   └── ...
│
├── controller/                        # Controladores (lógica de negócio)
│   ├── auth_controller.dart
│   ├── home_controller.dart
│   ├── produtos_controller.dart
│   ├── servicos_controller.dart
│   ├── carrinho_controller.dart
│   ├── pedido_controller.dart
│   ├── agendamento_controller.dart
│   ├── favoritos_controller.dart
│   ├── dashboard_controller.dart
│   ├── notificacao_controller.dart
│   └── ...
│
├── services/                          # Serviços externos
│   └── fcm_service.dart               # Firebase Messaging
│
├── utils/                             # Utilitários
│   ├── validators.dart                # Validadores genéricos
│   └── endereco_validators.dart       # Validadores de endereço
│
├── view/                              # Camada de apresentação
│   ├── auth/                          # Telas de autenticação
│   │   ├── auth_gate.dart
│   │   ├── auth_page.dart
│   │   ├── forgot_password_page.dart
│   │   ├── email_verification_pending_page.dart
│   │   └── email_verified_success_page.dart
│   │
│   ├── user_views/                    # Telas do utilizador
│   │   ├── home/                      # Home (com widgets de seção)
│   │   ├── servicos/                  # Lista e detalhe de serviços
│   │   ├── produtos/                  # Lista e detalhe de produtos
│   │   ├── carrinho/                  # Carrinho e checkout
│   │   ├── favoritos/                 # Favoritos
│   │   ├── agendamento/               # Agendamento
│   │   ├── compra/                    # Histórico de pedidos
│   │   ├── perfil/                    # Perfil do utilizador
│   │   └── widgets/                   # Widgets compartilhados (drawer, footer)
│   │
│   ├── admin_views/                   # Telas do painel administrativo
│   │   ├── admin_layout.dart
│   │   ├── pages/
│   │   │   ├── admin_dashboard_page.dart
│   │   │   ├── admin_produtos_page.dart
│   │   │   ├── admin_servicos_page.dart
│   │   │   ├── admin_agendamentos_page.dart
│   │   │   ├── admin_clientes_page.dart
│   │   │   ├── admin_compras_page.dart
│   │   │   └── admin_configuracoes_page.dart
│   │   └── widgets/
│   │
│   └── notificacoes/                  # Painel de notificações
│
└── assets/images/                     # Imagens (logo, capa)
```

### Padrões utilizados
- **State Management** — `GetX` / `Provider` (controladores por domínio)
- **Firebase** — Auth, Firestore, Storage, Messaging, Functions
- **Clean Architecture** — separação Model / Controller / View
- **Reactive Programming** — streams do Firestore para atualizações em tempo real

---

## ⚙️ Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| 📱 **Framework** | [Flutter 3.x](https://flutter.dev) (Dart 3.9) |
| 🔥 **Backend** | [Firebase](https://firebase.google.com) — Auth, Firestore, Storage, Messaging, Functions |
| ☁️ **Cloud Functions** | [Node.js 20](https://nodejs.org) + Firebase Functions v2 |
| 📧 **Email** | Nodemailer (Gmail) com templates personalizados |
| 🎨 **Design** | Material Design 3 + tema customizado |
| 📊 **Gráficos** | [fl_chart](https://pub.dev/packages/fl_chart) |
| 📱 **Ícones** | [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter) |
| 🌐 **Plataformas** | Android, iOS, Web |
| 🔗 **Deep Links** | [url_launcher](https://pub.dev/packages/url_launcher) |
| 📸 **Imagens** | [image_picker](https://pub.dev/packages/image_picker) |

---

## 🚀 Começando

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9+)
- [Node.js](https://nodejs.org) (20+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Conta Firebase (para credenciais)

### 1. Clonar o repositório

```bash
git clone https://github.com/seu-username/loahstudio.git
cd loahstudio
```

### 2. Instalar dependências Flutter

```bash
flutter pub get
```

### 3. Configurar Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione os apps **Android**, **iOS** e **Web** ao projeto
3. Copie os `google-services.json` (Android), `GoogleService-Info.plist` (iOS) e a `firebase_options.dart`
4. Coloque os arquivos nos diretórios corretos:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

> 📋 O `firebase.json` já contém a configuração do projeto `myloahstudio`. Atualize os IDs de app conforme o seu projeto Firebase.

### 4. Configurar Cloud Functions

```bash
cd functions
npm install
```

Configure os segredos do Gmail (usados para envio de emails) no Firebase:

```bash
firebase functions:config:set gmail.email="seu-email@gmail.com" gmail.password="sua-senha-app"
```

### 5. Executar

```bash
# App Flutter (Android / iOS / Web)
flutter run

# Emulador Firebase (opcional)
firebase emulators:start

# Cloud Functions localmente
cd functions && npm run serve
```

### 6. Deploy

```bash
# Deploy do Firebase (Hosting + Functions)
firebase deploy

# Ou apenas Hosting
firebase deploy --only hosting

# Ou apenas Functions
firebase deploy --only functions
```

---

## 📁 Estrutura de Ficheiros Principal

```
loahstudio/
├── android/                   # App Android
├── ios/                       # App iOS
├── web/                       # App Web
├── functions/                 # Cloud Functions (Node.js)
│   ├── index.js               # Cloud Functions principais
│   ├── mailer.js              # Serviço de email (Nodemailer)
│   ├── emailTemplates.js      # Templates de email
│   ├── firestore.rules        # Regras de segurança Firestore
│   └── package.json
├── lib/                       # Código-fonte Flutter
├── assets/images/             # Imagens do app
├── public/                    # Hosting estático (index.html)
├── test/                      # Testes
├── pubspec.yaml               # Dependências Flutter
├── analysis_options.yaml      # Regras de análise
├── firebase.json              # Configuração Firebase
├── cors.json                  # Configuração CORS
└── README.md                  # Este ficheiro! 🎉
```

---

## 📄 Regras de Segurança Firestore

As regras de segurança estão em `functions/firestore.rules` e definem quem pode ler/escrever cada coleção (`users`, `produtos`, `pedidos`, `agendamentos`, etc.).

---

## 🤝 Contribuindo

1. **Faça um fork** do projeto
2. Crie uma **feature branch**: `git checkout -b feature/nova-funcionalidade`
3. **Commit** com mensagens claras: `git commit -m 'Adiciona nova funcionalidade'`
4. **Push** para a branch: `git push origin feature/nova-funcionalidade`
5. Abra um **Pull Request** 🚀

---

## 📄 Licença

Este projeto está licenciado sob a **Licença MIT** — consulte o ficheiro [LICENSE](LICENSE) para mais detalhes.

---

## 🙏 Agradecimentos

- [Flutter Team](https://flutter.dev) pelo framework incrível
- [Firebase](https://firebase.google.com) pelo ecossistema backend
- [Font Awesome](https://fontawesome.com) pelos ícones

---

<div align="center">

Feito com 💜 pela equipa **Loah Stúdio**

<br/>

<picture>
  <source srcset="https://img.shields.io/badge/-Flutter-02569B?style=flat-square&logo=flutter" media="(prefers-color-scheme: light)">
  <img src="https://img.shields.io/badge/-Flutter-02569B?style=flat-square&logo=flutter" alt="Flutter">
</picture>
&nbsp;
<a href="https://firebase.google.com"><img src="https://img.shields.io/badge/-Firebase-FFCA28?style=flat-square&logo=firebase" alt="Firebase"></a>
&nbsp;
<a href="https://nodejs.org"><img src="https://img.shields.io/badge/-Node.js-339933?style=flat-square&logo=node.js" alt="Node.js"></a>

<br/><br/>

**Loah Stúdio** — Beleza ao seu alcance. 🌸

</div>
