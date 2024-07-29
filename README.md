---

# Proyecto de Infraestructura en AWS con Terraform

Este proyecto crea una infraestructura en AWS utilizando Terraform. La infraestructura incluye una VPC con subredes públicas y privadas, un balanceador de carga, instancias EC2 con autoescalado, y un bastión para acceder mediante SSH a las EC2 de la red privada.

## Requisitos

- **Tener terraform en la version 1.9.3**
- **Tener AWS CLI**
- **Configurar el fichero de creedenciales de aws por lo general se encuentra en ~/.aws/credentials**

## Cómo Ejecutar el Proyecto

1. **Inicializar Terraform**:
    
   ```sh
   terraform init
   ```
2. **Verificar Plan**:
    
    Hacemos un plan para verificar lo que se va a desplegar, en este caso pedirá que introduzcamos nuesta IP          publica y la KeyPair para la conexión ssh.
    ```sh
    terraform plan
    ```

3. **Aplicar la Configuración**:

    Nos pedirá que introduzcamos nuestra ip pública y el KeyName generado desde el dashboard de AWS
   ```sh
   terraform apply
   ```
## Pruebas

Hecho el despligue de nuestra infraestructura, en los outputs podremos ver el DNS del ALB formateado con el puerto 8080

```sh
load_balancer_dns = "http://loadBalancerApp-1904107911.us-east-1.elb.amazonaws.com:8080"
```

Con este dato desde nuestro host podremos realizar un **curl** y verifciar que nos da un 200 OK como respuesta. Ya que las instancias EC2 del autoescaling group estan provisioandas con el0 servicio httpd que está en la escucha del puerto 8080

```sh
curl -I "http://loadBalancerApp-1904107911.us-east-1.elb.amazonaws.com:8080"
```

Si queremos conectarnos  por ssh al bastion tendremos el output de la IP del bastion

```sh
ssh -i <ruta de la keyPair> ec2-user@<ip del bastion>
```

Ahora si queremos hacer conexión ssh desde el bastión a nuestras EC2 del autoescaling group tendremos que pasar nuestra clave .pem generada por el KeyPair desde nuestro host al bastion

```sh
scp -i path/to/keyPair.pem path/to/keyPair.pem ec2-user@bastion-public-ip:/home/ec2-user/private-key.pem
```
Ahora si queremos saber las IP'S de las instancias de la red privada tendremos que ejecutar

```sh
terraform plan
```
En la salida podremos ver las IP's de las instancias de la red privada

```sh
Changes to Outputs:
  ~ bastion_ip              = "174.129.70.47" -> (known after apply)
  ~ private_ips             = [
      + "10.0.3.55",
      + "10.0.3.90",
    ]
```

De esta forma la variable de las ip's privadas contendrá dichas ip's. De esta forma podremos conectarnos desde el bastión a las instancias de la red privada.

## Problemas Conocidos

- **Acceso al ALB desde el Bastión**:  Uno de los problemas es que al configurar el grupo de seguridad solo doy acceso al puerto 8080 a mi IP Públic, y por ese motivo desde el bastion no se puede realizar un curl a la URL del ALB. 

## Descripción de la Infraestructura

### Estructura de la VPC y Subredes

- **VPC**: Se ha creado una VPC llamada `my_vpc` con un rango de direcciones CIDR `10.0.0.0/16`.
- **Subredes**:
  - **Subredes Públicas**: `10.0.1.0/24` y `10.0.2.0/24`.
  - **Subred Privada**: `10.0.3.0/24`.

### Grupos de Seguridad

- **Security Group ALB (`security_group_alb`)**: Permite el tráfico entrante en el puerto 8080 desde una IP específica (`var.allowed_ip`) y en el puerto 22 desde el rango `10.0.0.0/8`.

- **Security Group EC2 (`security_group_ec2`)**: Permite el tráfico entrante desde el **Security Group del ALB** en todos los puertos y el tráfico SSH (puerto 22) desde cualquier IP (`0.0.0.0/0`).

### Balanceador de Carga (ALB)

- Se ha configurado un Application Load Balancer que distribuye el tráfico a instancias EC2 en el puerto 8080. El ALB utiliza el Security Group `security_group_alb`.

### Auto Scaling Group (ASG)

- Un grupo de autoescalado que mantiene 2 instancias EC2, utilizando una plantilla de lanzamiento (`aws_launch_template.web`).

### Bastión EC2

- Una instancia EC2 para bastión configurada en una subred pública, desde esta instancia podremos realizar conexion SSH las instancias de la subred privada.

---