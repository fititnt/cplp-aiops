
# Build
docker build -t reverse-proxy-for-free-basics .

docker run --name proxy-inclusao-etica-ai -p 8080:80 -d reverse-proxy-for-free-basics

# Parar o conteiner e apagar
docker rm -f proxy-inclusao-etica-ai

# Apagar imagem do conteiner (use para rebuildar)
docker rmi proxy-inclusao-etica-ai

# Apenas para testar inclusao.etica.ai com um subdominio fake
# Com isso eu posso acessar http://rp4fb.inclusao.etica.ai ou http://rp4fb.inclusao.etica.ai:8080/
# e tentará acessar https://inclusao.etica.ai
# sudo vim /etc/hosts
127.0.0.1   rp4fb.inclusao.etica.ai

# Full drill
docker rm -f proxy-inclusao-etica-ai && \
    docker build -t reverse-proxy-for-free-basics . && \
    docker run --name proxy-inclusao-etica-ai -p 8080:80 reverse-proxy-for-free-basics