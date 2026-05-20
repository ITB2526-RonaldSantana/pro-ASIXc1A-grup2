# Guía de Despliegue de Infraestructura AWS

## FASE 1: Configuración de la Red Pública Global
Para evitar los problemas de falta de hardware (como el error en us-east-1e), centralizaremos toda la infraestructura en la zona us-east-1a, que tiene compatibilidad total.

### 1. Crear la VPC
- Ve a la consola de **VPC** -> **Your VPCs** -> **Create VPC**.
- Selecciona **VPC only**.
- **Name tag:** `VPC-Infraestructura`
- **IPv4 CIDR block:** `10.0.0.0/16`
- Haz clic en **Create VPC**.

### 2. Crear la Subred Pública
- En el menú izquierdo, ve a **Subnets** -> **Create subnet**.
- Selecciona `VPC-Infraestructura`.
- Configura los detalles:
  * **Subnet name:** `Subred-Publica-Nodos`
  * **Availability Zone:** Selecciona explícitamente **`us-east-1a`**.
  * **IPv4 CIDR block:** `10.0.1.0/24`
- Haz clic en **Create subnet**.

### 3. Crear y conectar el Internet Gateway (IGW)
- En el menú izquierdo, ve a **Internet gateways** -> **Create internet gateway**.
- **Name tag:** `IGW-Infraestructura` y haz clic en **Create**.
- En la pantalla siguiente, haz clic en **Actions** -> **Attach to VPC**.
- Selecciona tu `VPC-Infraestructura` y haz clic en **Attach internet gateway**.

### 4. Configurar la Tabla de Rutas
- En el menú izquierdo, ve a **Route tables**.
- Selecciona la tabla de rutas asociada a tu `VPC-Infraestructura` (puedes ponerle de nombre `Tabla-Publica`).
- Ve a la pestaña inferior **Routes** -> **Edit routes**.
- Haz clic en **Add route**:
  * **Destination:** `0.0.0.0/0`
  * **Target:** Selecciona *Internet Gateway* y elige tu `IGW-Infraestructura`.
- Haz clic en **Save changes**.

---

## FASE 2: Creación de los Security Groups (Cortafuegos)
Crearemos dos grupos de seguridad en **VPC** -> **Security groups** -> **Create security group**. Tu dirección IP de casa se añadirá automáticamente al seleccionar "My IP".

### Grupo 1: `SG-Servidor1-Web` (Para el Servidor 1)
- **VPC:** `VPC-Infraestructura`
- **Inbound Rules (Reglas de entrada):**
  * **HTTP (80)** | Source: `Anywhere-IPv4 (0.0.0.0/0)`
  * **HTTPS (443)** | Source: `Anywhere-IPv4 (0.0.0.0/0)`
  * **SSH (22)** | Source: `My IP` (Solo tu casa)

### Grupo 2: `SG-Nodos-Internos` (Para los Servidores 2A al 4)
- **VPC:** `VPC-Infraestructura`
- **Inbound Rules (Reglas de entrada):**
  * **SSH (22)** | Source: `My IP` (Para que tu PC conecte directo)
  * **LDAP (389) y LDAPS (636)** | Source: `Custom` -> Selecciona el ID de `SG-Servidor1-Web`
  * **MySQL (3306)** | Source: `Custom` -> Escribe el CIDR `10.0.0.0/16` (Comunicación interna)
  * **Custom UDP/TCP (12201 o 514 para Logs)** | Source: `Custom` -> Escribe `10.0.0.0/16`

---

## FASE 3: Lanzamiento de las Instancias EC2 (Nodos)
Ve a **EC2** -> **Instances** -> **Launch instances**. Para cada uno de los 7 servidores, aplica la siguiente configuración exacta:

### Configuración Común para TODOS los Servidores:
- **Application and OS Images (AMI):** `Ubuntu Server 24.04 LTS` (64-bit x86).
- **Key pair:** Selecciona tu llave `.pem` existente (la que tienes guardada en tu PC).
- **Network Settings (Editar):**
  * **VPC:** `VPC-Infraestructura`
  * **Subnet:** `Subred-Publica-Nodos`
  * **Auto-assign public IP:** **`Enable`** (Crucial para que tengan IP externa)

### Especificaciones Individuales por Servidor:
Aplica el nombre, tamaño y grupo de seguridad correspondiente a cada uno antes de lanzar:

| Nombre de Instancia | Tipo de Instancia | Security Group a seleccionar |
| :--- | :--- | :--- |
| `Servidor 1 (Web / SFTP)` | `t3.small` | `SG-Servidor1-Web` |
| `Servidor 2A (LDAP)` | `t3.small` | `SG-Nodos-Internos` |
| `Servidor 2B (Logs)` | `t3.small` | `SG-Nodos-Internos` |
| `Servidor 3A (Streaming Audio)` | `t3.medium` | `SG-Nodos-Internos` |
| `Servidor 3B (Streaming Video)` | `t3.medium` | `SG-Nodos-Internos` |
| `Servidor 3C (Base de Datos)` | `t3.medium` | `SG-Nodos-Internos` |
| `Servidor 4 (Backups)` | `t3.micro` | `SG-Nodos-Internos` |