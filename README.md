# Aplicativo Uber Clone Passageiro

![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)
![Badge em Kotlin](http://img.shields.io/static/v1?label=LENGUAGE&message=%20DART&color=BLUEN&style=for-the-badge)

<p>
  Aplicativo desenvolvido em Dart/Flutter utilizando uma arquitetura modular. Permite ao usuário solicitar viagens de carro ou moto, exibir o trajeto no mapa com informações detalhadas como localização em tempo real, valor estimado, distância e duração da viagem, tudo antes da confirmação.
</p>

#### .
[Atualização do app esta na branch atualizacao_app](https://github.com/R0nald0/Uber_Clone/tree/atualizacao_app)

### Imagens do App
<img src="https://github.com/user-attachments/assets/1eb71fb7-f2c9-4d76-bf38-92a0878187b3"  height="450em">
<img src="https://github.com/user-attachments/assets/81e24dbf-5289-4f0c-8c7f-d83acb39432a"  height="450em">
<img src="https://github.com/user-attachments/assets/47eb8e78-3d79-484b-8513-177efbbff6ae"  height="450em">


### Funcionalidades do App
---
 
 * solicitações de viagens
 * exibição no mapa. 
 * realizar viagens.
 * criação de perfil

 ## 🔧 Instalação e Execução

1. Clone o repositório:
   ```bash
   https://github.com/R0nald0/Uber_Clone
   ```

2. Instale as dependências:
   ```bash
    flutter pub get```

3. Execute o projeto
   ```bash
    flutter run```
  
Aplicativo desenvolvido ultilizando 
 - Flutter Modular para gerenciamento de rotas e  navegação,Injecão de dependência.(Futuramente será trocado pelo Flutter Get_It)
 - Firebase Firestore - para gravações de dados dos usuários e das viagens. 
 - Firebase Auth - para autenticação dos usuário,verificação do estado do usuáio(online/offline)
 - Firebase Storage - para gravações de imagens de perfis
 - Google Maps - para exibição de marcadores de posição,exibição e controle do mapa
 - Geolocalizacao - dados de localização,verificação de permissões de localização
 - Places - exbição de nomes de lugares no app
 - Persistência de dados offline com shared_preferences e local Storage
 - Gerenciamento de estado com o Mobx

![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

**Desenvolvido no Curso Flutter 2020 --Jamilton Damascesno**
