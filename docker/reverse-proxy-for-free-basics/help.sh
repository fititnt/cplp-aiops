
# Build
docker build -t reverse-proxy-for-free-basics .

docker run --name proxy-inclusao-etica-ai -p 8080:80 -d reverse-proxy-for-free-basics

# Parar o conteiner e apagar
docker stop proxy-inclusao-etica-ai
docker rm proxy-inclusao-etica-ai

# Apagar imagem do conteiner (use para rebuildar)
docker rmi proxy-inclusao-etica-ai