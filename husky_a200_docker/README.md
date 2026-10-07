# Husky A200 em Docker (ROS 2 Jazzy)

Este projeto reproduz os cinco comandos da sessão Terminator: Zenoh, Gazebo, RViz, Nav2 e SLAM. A configuração do A200, o pacote `fees02_description`, as alterações locais nos launches/Nav2 e o ajuste de aderência das rodas estão incluídos aqui. Os arquivos originais da simulação no computador de origem não são modificados.

## Requisitos

- Docker Engine com Docker Compose v2 no Linux, ou Docker Desktop com WSL2 no Windows.
- Computador `x86_64/amd64` com memória suficiente para Gazebo, RViz e Nav2 (recomendado: 8 GB livres ou mais). No Windows, configure memória adequada para o WSL2.
- Internet para baixar a imagem ROS e os pacotes na primeira construção.

O Gazebo e o RViz usam renderização OpenGL por software no contêiner. Não é necessário X11, WSLg nem GPU no host. O desempenho gráfico pode ser menor que no sistema nativo.

## Iniciar

No Linux, em um terminal na pasta deste projeto:

```bash
docker compose up --build
```

Se você acabou de adicionar seu usuário ao grupo `docker`, abra um novo login/terminal ou execute `newgrp docker` antes do comando acima.

No Windows, abra a pasta do projeto em um terminal WSL2 e execute o mesmo comando. Em seguida, abra **http://localhost:6080/vnc.html?autoconnect=true** no navegador do host. O primeiro build pode demorar. O mundo inicial é `solar_farm`, como no `simulation.launch.py` da instalação original.

Para parar, pressione `Ctrl+C` no terminal que executa Compose, ou use `docker compose down`. O volume `robot_setup` guarda os arquivos gerados pelo Clearpath; os volumes `ros_build` e `ros_install` guardam o build dos seus nós. Não execute `docker compose down -v` se quiser mantê-los.

## Criar e compilar nós ROS 2

Coloque os pacotes novos em `ros_ws/src` no host; o diretório é montado dentro do contêiner. Por exemplo, em outro terminal:

```bash
docker compose exec --user "$(id -u):$(id -g)" -e HOME=/tmp sim /opt/husky/scripts/entrypoint.sh bash
cd /workspaces/ros_ws/src
ros2 pkg create --build-type ament_python --node-name meu_no meu_pacote --dependencies rclpy std_msgs
exit
docker compose exec --user "$(id -u):$(id -g)" -e HOME=/tmp sim /opt/husky/scripts/build-workspace.sh
```

Depois do build, abra um novo shell e carregue o workspace para executar seus nós:

```bash
docker compose exec --user "$(id -u):$(id -g)" -e HOME=/tmp sim /opt/husky/scripts/entrypoint.sh bash
source /workspaces/ros_ws/install/setup.bash
ros2 run meu_pacote meu_no
```

Os exemplos usam o UID/GID do terminal Linux ou WSL2 para que os arquivos criados em `ros_ws/src` pertençam ao usuário do host. Execute os comandos no terminal WSL2 também no Windows e mantenha o projeto no sistema de arquivos do WSL. Edite `ros_ws/src/meu_pacote/meu_pacote/meu_no.py` para implementar o nó; depois rode o build novamente. Evite alternar builds como root e como usuário normal no mesmo workspace, pois os artefatos podem ficar com donos diferentes.

## Estrutura e limites

- `config/robot.yaml`: cópia da configuração do A200; o caminho do workspace nativo foi removido.
- `bundled/fees02_description`: pacote local exigido pelo `robot.yaml`, compilado na imagem.
- `overrides/`: cópias das cinco alterações locais detectadas nos pacotes ROS instalados. O Dockerfile coloca essas cópias **dentro da imagem** após instalar os pacotes, sem editar a simulação do host.
- `ros_ws/src`: seus novos pacotes ROS 2, versionáveis no GitHub.

O navegador VNC está publicado somente em `127.0.0.1:6080` e o servidor VNC não usa senha. Não exponha a porta diretamente na rede. Esta imagem usa pacotes apt atuais do ROS Jazzy; se uma atualização deles mudar a compatibilidade com os overrides, pode ser necessário ajustar as cópias nesta pasta.

Validado em Ubuntu 24.04 `amd64`: a imagem compilou; Gazebo, Zenoh, RViz, Nav2 e SLAM iniciaram; o Nav2 e o SLAM ficaram `active`; o noVNC respondeu em `localhost:6080`; e um pacote Python temporário compilou e executou com `ros2 run`. O RViz pode registrar um aviso GLSL com renderização por software, mas a visualização do robô, laser e mapa foi confirmada. A execução no Windows/WSL2 ainda não foi testada nesta máquina.
