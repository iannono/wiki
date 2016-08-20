
2016-4-21
=========

:docker-machine

docker-machine是用来与虚拟机进行交互， 包括启动， 暂停， 设置虚拟机环境等.
这其中的虚拟机就包括本地的机器环境和云端的机器环境

```
# 查看当前机器上可用的虚拟机(假设当前虚拟机的名字为default)
docker-machine ls
docker-machine ip default
docker-machine status default
docker-machine stop default
docker-machine start default


# 如果不是通过docker terminal启动， 如何配置docker
# 检查当前的docker是否正常运行
docker ps
# 查看default的环境配置
docker-machine env default

# 通过docker-client 与docker engine进行交互
# 配置image 和 container
docker pull [image name]
docker run [image name]
docker images
docker ps

# 抓取一个image 并运行
docker pull hello-world
docker run hello-world
# 查看所有的container
docker ps -a
docker stop [container id]
docker rm [container id]
docker rmi [image id]


# 抓取nginximage
docker pull kitematic/hello-world-nginx
# 前一个80代表了vm的端口， 后一个80代表container的端口
docker run -p 80:80 kitematic/hello-world-nginx

# 如何将source coder放入container
1. 创建一个container volume并指向source code
valume 是container中的一种特殊的文件目录类型
并能够在container间共享和重用
更新image不会影响volume
删除container也不会影响volume
2. 添加source code到custom image, 以便用于创建一个container

# 创建一个volume(-v 代表创建一个volume， 后接的参数是container volume, pwd代表host location)
docker run -p 8080:3000 -v /var/www node
docker run -p 8080:3000 -v $(pwd):/var/www node
docker inspect mycontainer
# 同时删除掉volume
docker rm -v [container id]

# example for volume(在node image中运行express)
docker run -p 8080:3000 -v $(pwd):/var/www -w "/var/www" node npm start


# docker file
FROM [image name]:[version]

# example
FROM node:latest
MAINTAINER Ian

ENV NODE_ENV=production
ENV PORT=3000

COPY . /var/www
WORKDIR /var/www

RUN npm install
EXPOSE $PORT
ENTRYPOINT ["npm", "start"]

# use docker file to build a custom image
docker build [-f Dockerfile] -t <your username(tag name)>/node .

# push image to docker hub
docker login
docker push <your username>/node


# linking container by name
docker run -d --name my-postgres postgres
docker run -d -p 5000:5000 --link my-postgres:postgres(linked container alias) <username>/node

example:
docker build -f node.dockfile -t <username>/node .
docker run -d --name my-mongodb mongo
docker run -d -p 5000:5000 --link my-mongodb:mongo <username>/node

docker exec [container id] command

# container network
docker network create --driver bridge isolated_network
docker run -d --net=isolated_network --name mongodb mongo

# docker compose
docker-compose build
docker-compose up
docker-compose down
docker-compose down --rmi all --volumes
docker-compose logs
docker-compose ps
docker-compose stop
docker-compose start
docker-compose rm

# docker compose file and docker services
```

https://yeasy.gitbooks.io/docker_practice/content/compose/intro.html
www.daocloud.io
https://stackfiles.io
https://docs.docker.com/compose/rails/
https://blog.codeship.com/running-rails-development-environment-docker/
https://semaphoreci.com/community/tutorials/dockerizing-a-ruby-on-rails-application

2016-4-20
=========

:docker

```bash
brew install caskroom/cask/brew-cask
brew cask install virtualbox
brew install docker docker-machine
docker-machine create --driver virtualbox default
eval "$(docker-machine env default)"

docker-machine start
docker-machine env default

add to .zshrc
eval `docker-machine env 2>/dev/null`

brew install docker-compose

docker build .

docker-compose run web rake db:create db:setup
docker-machine ip default
docker-compose up
```
