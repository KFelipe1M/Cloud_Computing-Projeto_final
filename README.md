# ☁️ Cloud Computing – Projeto Final

## 📌 Sobre o Projeto

Este repositório contém os arquivos e materiais desenvolvidos para o Projeto Final da disciplina de **Computação em Nuvem (Cloud Computing)**.

O projeto tem como finalidade reunir e organizar os recursos, configurações, documentações e scripts relacionados ao desenvolvimento da atividade acadêmica, utilizando o GitHub como ferramenta de versionamento e colaboração entre os integrantes da equipe.

O projeto consiste na implementação de uma infraestrutura de Computação em Nuvem utilizando a plataforma LXD, com o objetivo de gerenciar contêineres, redes virtuais, armazenamento e serviços de forma organizada.
A solução utiliza o Ubuntu 24.04 como imagem-base e prevê a execução de três serviços principais: Nginx, responsável pelo proxy reverso; Nextcloud, responsável pela aplicação; e MariaDB, utilizado como banco de dados.
A infraestrutura foi planejada com dois ambientes, Produção (PROD) e Desenvolvimento (DEV), permitindo separar os serviços e facilitar a organização e os testes. Para isso, são utilizados recursos como redes independentes, perfis de configuração, instâncias e volumes persistentes.


## 🎓 Finalidade Acadêmica

Projeto desenvolvido como atividade acadêmica da disciplina de Computação em Nuvem, com o objetivo de aplicar os conhecimentos adquiridos durante o período letivo.


---

## 📁 Estrutura do Repositório

O repositório está organizado da seguinte forma:

```text
Cloud_Computing-Projeto_final/
│
├── conf/       # Arquivos de configuração
├── docs/       # Documentação do projeto
├── profiles/   # Arquivos relacionados aos perfis
├── scripts/    # Scripts do projeto
│
├── .gitignore
└── README.md
```

## 👨‍💻 Integrantes do Grupo

| Nome | Matrícula |
|---|---|
| Kauã Filipe Moreno Marques | 01791750 |
| Lucas Teobaldo Cruz | 01802436 |
| Victor Ribeiro Barbosa de Menezes | 01791754 |
| Pablo Henrique Ramos de Oliveira | 01837789 |

## 🛠️ Tecnologias e Ferramentas
-----------------------------------------------------------------------
  Tecnologia                          Utilização
  ----------------------------------- -----------------------------------
  **Ubuntu Server**                   Sistema operacional da máquina
                                      virtual que hospeda a
                                      infraestrutura.

  **Oracle VirtualBox**               Virtualização da máquina Ubuntu.

  **LXD**                             Gerenciamento dos containers e dos
                                      recursos de infraestrutura.

  **Nginx**                           Proxy reverso responsável por
                                      receber as conexões HTTP/HTTPS e
                                      encaminhá-las à aplicação.

  **Apache HTTP Server**              Servidor web utilizado pelo
                                      container da aplicação Nextcloud.

  **Nextcloud**                       Plataforma de armazenamento e
                                      compartilhamento de arquivos.

  **MariaDB**                         Sistema gerenciador de banco de
                                      dados utilizado pelo Nextcloud.

  **OpenSSL / TLS**                   Geração e utilização de
                                      certificados para estabelecer
                                      conexões HTTPS.

  **Bash e ferramentas Linux**        Execução de comandos e tarefas de
                                      administração e diagnóstico.
  -----------------------------------------------------------------------


## 📂 Execução

Na máquina virtual Ubuntu, confira os containers do projeto:

``` bash
lxc list --project final-equipe00
```

Inicie os serviços, caso estejam parados:

``` bash
lxc start db --project final-equipe00
lxc start app --project final-equipe00
lxc start proxy --project final-equipe00
```

Se a segunda aplicação e o ambiente de testes forem necessários:

``` bash
lxc start app2 --project final-equipe00
lxc start test-dev --project final-equipe00
```

Confira novamente o estado:

``` bash
lxc list --project final-equipe00
```

A ordem recomendada é iniciar primeiro o banco de dados, depois a
aplicação e, por último, o proxy reverso.

## 4. Verificação dos serviços

### Banco de dados

Confira se o MariaDB está ativo:

``` bash
lxc exec db --project final-equipe00 -- systemctl status mariadb
```

### Aplicação Nextcloud

Consulte o estado de instalação do Nextcloud:

``` bash
lxc exec app --project final-equipe00 -- \
  sudo -u www-data php /var/www/nextcloud/occ status
```

Teste o endpoint de status a partir do container do proxy:

``` bash
lxc exec proxy --project final-equipe00 -- \
  curl -i http://10.10.10.11/status.php
```

Uma resposta HTTP `200` com os dados de status em JSON indica que o
endpoint da aplicação respondeu ao teste.

### Nginx

Valide a configuração:

``` bash
lxc exec proxy --project final-equipe00 -- nginx -t
```

Confira o serviço:

``` bash
lxc exec proxy --project final-equipe00 -- systemctl status nginx
```

## 5. Acesso pelo navegador

As portas utilizadas pelo projeto são:

  Protocolo      Porta Finalidade
  ----------- -------- --------------------------------
  HTTP          `8081` Acesso HTTP publicado no host
  HTTPS         `8444` Acesso HTTPS publicado no host

Quando a VM estiver utilizando NAT no VirtualBox, configure o
redirecionamento de portas no Adaptador 1:

    Porta no hospedeiro IP do convidado     Porta no convidado
  --------------------- ----------------- --------------------
                 `8081` `10.0.2.15`                     `8081`
                 `8444` `10.0.2.15`                     `8444`

Com o redirecionamento configurado, o acesso no próprio computador
hospedeiro pode ser feito por:

``` text
http://localhost:8081
https://localhost:8444
```

Para acessar a partir de outro computador na mesma rede, utilize o
endereço IPv4 do computador hospedeiro, desde que o firewall permita as
conexões:

``` text
http://IP_DO_COMPUTADOR:8081
https://IP_DO_COMPUTADOR:8444
```

Substitua `IP_DO_COMPUTADOR` pelo endereço obtido com `ipconfig` no
Windows. No ambiente utilizado durante os testes, o endereço informado
foi `10.0.0.172`; esse valor pode mudar conforme a rede.

O certificado HTTPS foi emitido para `servico.lab`. Portanto, acessar
pelo endereço IP ou por `localhost` pode gerar um aviso de
incompatibilidade do nome do certificado. Para validar o HTTPS sem esse
aviso, o nome `servico.lab` deve resolver para o endereço correto e a
autoridade certificadora do projeto deve ser confiável no computador
cliente.

## 6. Diagnóstico de conectividade

Na VM Ubuntu, confira se as portas estão em escuta:

``` bash
sudo ss -lntp | grep -E ':(8081|8444)\\b'
```

No Windows, teste as portas publicadas:

``` powershell
Test-NetConnection IP_DO_COMPUTADOR -Port 8081
Test-NetConnection IP_DO_COMPUTADOR -Port 8444
```

O resultado `TcpTestSucceeded : True` indica que a conexão TCP foi
estabelecida. Isso confirma a conectividade da porta, mas não garante,
por si só, que o Nextcloud esteja sendo exibido corretamente.

Se o navegador mostrar a página padrão do Nginx, a conexão chegou ao
servidor web, mas ainda é necessário conferir a seleção do site e a
configuração do proxy reverso:

``` bash
lxc exec proxy --project final-equipe00 -- nginx -T
lxc exec proxy --project final-equipe00 -- ls -la /etc/nginx/sites-enabled/
lxc exec proxy --project final-equipe00 -- cat /etc/nginx/sites-available/servico
```

## 7. Encerramento

Para parar os serviços, utilize:

``` bash
lxc stop proxy --project final-equipe00
lxc stop app --project final-equipe00
lxc stop db --project final-equipe00
```

Se `app2` ou `test-dev` tiverem sido iniciados, eles também podem ser
parados:

``` bash
lxc stop app2 --project final-equipe00
lxc stop test-dev --project final-equipe00
```

**Projeto Final – Cloud Computing**

Desenvolvido em equipe.
