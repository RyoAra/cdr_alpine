echo $1
mkdir ./projects/$1

docker run --rm -it -p 8080:8080  \
     --mount type=bind,source="/var/local/projects/$1",target="/home/coder/project" \
     --env PASSWORD="$1" \
    alpine/codeserver code-server --auth=password --bind-addr=0.0.0.0:8080 