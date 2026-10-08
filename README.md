# Husky A200 — Docker (ROS 2 Jazzy)

Execute a simulação do Husky A200 com **Gazebo, RViz2, Nav2 e SLAM** no Windows ou Ubuntu.

**Requisitos:** computador `x86_64/amd64`, conexão à internet e **40 GB livres recomendados** durante a instalação (o uso real pode ser menor). Recomenda-se também **8 GB de RAM livres** para a simulação.

## Windows 10/11

**1. Instale o Ubuntu no WSL2** pelo PowerShell (como administrador):

```powershell
wsl --install -d Ubuntu-24.04
```

Reinicie o Windows se solicitado e abra **Ubuntu** pelo menu Iniciar. Configure o usuário na primeira execução.

```powershell
wsl -d Ubuntu-24.04
```

**2. Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/)** e ative **Settings (símbolo de engrenagem) → Resources → WSL Integration → Ubuntu-24.04**.

**3. No terminal Ubuntu (WSL2), baixe o projeto:**

```bash
git clone https://github.com/KrepsD/husky-docker.git
cd husky-docker/husky_a200_docker
```

**4. Baixe os pacotes e inicie a simulação:**

```bash
docker compose up --build
```

**5. Abra a interface gráfica no navegador:** http://localhost:6080/vnc.html?autoconnect=true

**6. Para finalizar a execução, dê ctrl + c no terminal que está rodando o docker, e caso queira rodar novamente, utilize o comando:**

```bash
docker compose up
```

## Ubuntu (instalado diretamente no computador)

**1. Instale o Docker Engine e o Compose** seguindo o [guia oficial para Ubuntu](https://docs.docker.com/engine/install/ubuntu/). Confirme a instalação:

```bash
sudo docker compose version
```

**2. Baixe o projeto:**

```bash
git clone https://github.com/KrepsD/husky-docker.git
cd husky-docker/husky_a200_docker
```

**3. Inicie a simulação:**

```bash
sudo docker compose up --build
```

**4. Abra a interface gráfica no navegador:** http://localhost:6080/vnc.html?autoconnect=true

> No Ubuntu, se você [configurar o Docker para uso sem `sudo`](https://docs.docker.com/engine/install/linux-postinstall/), poderá usar `docker compose` diretamente.

## Comandos úteis

**Abra outro terminal na pasta `husky_a200_docker` e liste os tópicos ROS 2:**

```bash
# Windows (WSL2)
docker compose exec sim bash
# Ubuntu nativo: use sudo docker compose exec sim bash, se necessário
ros2 topic list
```

**Pare os serviços** com `Ctrl+C` no terminal do Compose ou execute:

```bash
# No Ubuntu nativo, acrescente sudo se necessário
docker compose down
```

**Inicie novamente** sem reconstruir a imagem:

```bash
docker compose up
```

## Compatibilidade e espaço

- **Windows:** requer Docker Desktop com WSL2.
- **Ubuntu 22.04/24.04/26.04:** o Docker executa o ROS 2 Jazzy dentro do contêiner; a versão do Ubuntu hospedeiro não precisa ser 24.04. A instalação do Docker deve ser compatível com sua versão.
- **Ubuntu 20.04:** não é uma opção recomendada para uma nova instalação do Docker Engine, por ausência de suporte oficial atual.
- **Disco:** reserve **cerca de 40 GB livres** para build, imagens, cache e volumes; não é o tamanho fixo da instalação. No Ubuntu nativo, normalmente há menos sobrecarga que no Windows com WSL2/Docker Deskto


## Requisitos de hardware

| Componente | Mínimo para tentar rodar | Recomendado |
|---|---|---|
| **Processador** | Intel Core i5 ou Ryzen 5, 4 núcleos | Intel Core i7 ou Ryzen 7, 6–8 núcleos |
| **Arquitetura** | x86_64 (64 bits) | x86_64 (64 bits) |
| **Memória RAM** | 8 GB totais (limitante) | 16 GB ou mais |
| **Armazenamento livre** | 30 GB | 40–60 GB em SSD |
| **Placa de vídeo** | Integrada | Dedicada ou integrada moderna |
| **Sistema operacional** | Ubuntu compatível ou Windows com WSL2 | Ubuntu 24.04 LTS |

**Observação:** Os requisitos são estimativas para executar o Gazebo, RViz2, Nav2 e SLAM Toolbox simultaneamente. A configuração atual utiliza renderização gráfica por software, portanto não exige GPU dedicada. Recomenda-se pelo menos 8 GB de RAM livres.

