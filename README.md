# Husky A200 Docker no Windows (WSL2)

## 1. Instalar WSL2 e Ubuntu

Abra o **PowerShell como administrador** e instale o Ubuntu:

```powershell
wsl --install -d Ubuntu-24.04
```

Reinicie o Windows se solicitado e abra o Ubuntu pelo menu Iniciar (ou com o comando abaixo no PowerShell):

```powershell
wsl -d Ubuntu-24.04
```

## 2. Instalar Docker Desktop

Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/) e ative **Settings → Resources → WSL Integration → Ubuntu-24.04**.

No terminal Ubuntu, verifique se o Docker está disponível:

```bash
docker compose version
```

## 3. Baixar o projeto

No Ubuntu, instale o Git:

```bash
sudo apt update && sudo apt install -y git
```

Clone o repositório:

```bash
cd ~ && git clone https://github.com/KrepsD/husky-docker.git
```

Entre na pasta do projeto:

```bash
cd ~/husky-docker/husky_a200_docker
```

## 4. Iniciar a simulação

Construa a imagem e inicie o contêiner:

```bash
docker compose up --build
```

Abra a interface gráfica no navegador do Windows:

http://localhost:6080/vnc.html?autoconnect=true

## 5. Acessar o ROS 2

Abra **outro terminal Ubuntu** e entre na pasta do projeto:

```bash
cd ~/husky-docker/husky_a200_docker
```

Entre no contêiner:

```bash
docker compose exec sim bash
```

Liste os tópicos ROS 2:

```bash
ros2 topic list
```

Saia do contêiner:

```bash
exit
```

## 6. Parar e reiniciar

Pare a simulação com **Ctrl+C** no primeiro terminal ou execute:

```bash
docker compose down
```

Para iniciar novamente sem reconstruir a imagem:

```bash
docker compose up
```

> **Nota:** execute os comandos Docker no terminal Ubuntu (WSL2), com o Docker Desktop aberto. O projeto foi validado em Ubuntu Linux; a execução no Windows/WSL2 pode exigir ajustes.
