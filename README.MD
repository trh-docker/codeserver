# VS Code Server

Run [VS Code](https://github.com/Microsoft/vscode) on any machine anywhere and access it in the browser.

![Screenshot](https://github.com/cdr/code-server/blob/master/doc/assets/screenshot.png)

## Highlights

- **Code everywhere**
  - Code on your Chromebook, tablet, and laptop with a consistent development environment.
  - Develop on a Linux machine and pick up from any device with a web browser.
- **Server-powered**
  - Take advantage of large cloud servers to speed up tests, compilations, downloads, and more.
  - Preserve battery life when you're on the go as all intensive tasks runs on your server.
  - Make use of a spare computer you have lying around and turn it into a full development environment.

## Programmig Languages

- **Golang**
  - The Go programming language is an open source project to make programmers more productive.
        Go is expressive, concise, clean, and efficient. Its concurrency mechanisms make it easy to write programs that get the most out of multicore and networked machines, while its novel type system enables flexible and modular program construction. Go compiles quickly to machine code yet has the convenience of garbage collection and the power of run-time reflection. It's a fast, statically typed, compiled language that feels like a dynamically typed, interpreted language

- **Dartlang**
  - Dart is a client-optimized language for fast apps on any platform
    - Optimized for UI
        Mature and complete async-await for user interfaces containing event-driven code, paired with isolate-based concurrency
        A programming language optimized for building user interfaces with features such as the spread operator for expanding collections, and collection if for customizing UI for each platform
        A programming language that is easy to learn, with a familiar syntax

    - Productive development
        Make changes to your source code iteratively, using hot reload to instantly see the effect in the running app
        Write code using a flexible type system with rich static analysis and powerful, configurable tooling
        Do profiling, logging, and debugging with your code editor of choice

    - Fast on all platforms
        AOT-compile apps to native machine code for instant startup
        Target the web with complete, mature, fast compilers for JavaScript
        Run backend code supporting your app, written using a single programming language

Caddyserver v1 Caddyfile
```
example.com:80 {
    redir https://example.com
}
example.com:443 {
    basicauth / username password
    tls crt key
    proxy / codeserver:8080 {
        websocket
    }
    proxy / codeserver:8080 {
        transparent
    }
}
```
Docker Swarm or Docker Compose

```
---
version: "3.7"
configs:
  caddyfile:
    file: ./Caddyfile
    labels:
        caddy:
services:
  codeserver:
    image: quay.io/spivegin/codeserver
    volumes:
      - codedata:/home/coder/project
    deploy:
      restart_policy:
        condition: on-failure
    environment:
      - TZ=America/New_York
    networks:
      - net
  caddy:
    image: quay.io/spivegin/caddy_only:latest
    command: caddy -email ssl@example.com -agree=true -log stdout
    ports:
      - "80:80"
      - "443:443"
    networks:
      - net
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - acme:/opt/acme
    deploy:
      placement:
        constraints:
          - node.role == manager
      replicas: 1
      restart_policy:
        condition: on-failure
      resources:
        reservations:
          cpus: '0.35'
          memory: 250M
volumes:
    codedata:
    acme:
networks:
  net:
    external: false
```