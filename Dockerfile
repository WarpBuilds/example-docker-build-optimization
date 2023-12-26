# Our base image.
FROM ubuntu:22.04

# Sets the working directory for any instructions that follow it.
WORKDIR /build

# Copies all the files from the current directory and 
# adds them to the filesystem of the container.
COPY . .

# Upgrades all the installed packages using Ubuntu's package manager.
RUN apt update -y
RUN apt upgrade -y

# The default ubuntu image doesn't validate proxy.golang.org as CA, 
# so we need to manually add it. 
RUN apt install golang-go ca-certificates openssl -y
ARG cert_location=/usr/local/share/ca-certificates
RUN openssl s_client -showcerts -connect proxy.golang.org:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/proxy.golang.crt
RUN update-ca-certificates

# Installs Z-standard
RUN apt install zstd -y

# Verify Z-standard installation
RUN zstd --version

# Downloads dependencies of our project
RUN go mod download

# Builds the go binary
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o apiserver .

# Exposes port used by our backend server
EXPOSE 8080

# Runs the backend server
RUN chmod +x apiserver
ENTRYPOINT ["./apiserver"]