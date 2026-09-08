# Corporate IT HomeLab: Active Directory & SOC Monitoring

## Objetivo del Proyecto
Diseño e implementación de un entorno de red corporativa virtualizado "End-to-End" para practicar administración de sistemas, aplicación de políticas de grupo (GPOs) y auditoría de seguridad para Blue Team.

## Topología de la Arquitectura
*   **Host OS:** Linux Mint
*   **Hipervisor:** KVM/QEMU gestionado mediante Virt-Manager.
*   **Red Virtual:** Segmento en modo NAT (Rango `192.168.122.0/24`).
*   **Domain Controller (AD DS, DNS, DHCP):** Windows Server 2022 (IP Estática: `192.168.122.164`).
*   **Endpoint Cliente:** Windows 11 Enterprise (Hostname: `WS-CLIENTE01`).

<img width="596" height="590" alt="Topologia de red" src="https://github.com/user-attachments/assets/4b497ed8-5f40-4bef-b80d-b6ecab6604c0" />


## Servicios Core y Configuraciones Aplicadas
1. **Identity & Access Management (IAM):** Creación del bosque y dominio raíz (`homelab.local`). Diseño lógico con OUs y usuarios de prueba aplicando el Principio de Menor Privilegio (PoLP).
2. **Automatización con GPOs:**
   * **Mapeo de Unidades:** Despliegue de políticas (Preferences) para mapear automáticamente una ruta UNC compartida (SMB/NTFS de Solo Lectura) a la unidad Z: del cliente.
   * **Auditoría de Seguridad:** Configuración de *Advanced Audit Policies* a nivel de dominio para rastrear intentos de Logon y Management de cuentas (Success/Failure).

## Incidentes y Troubleshooting

### Incidente 1: Conflicto de resolución DNS por Rogue DHCP
* **Síntoma:** El cliente Windows 11 no podía resolver el nombre del dominio (`homelab.local`), bloqueando el Domain Join.
* **Diagnóstico:** El servicio `dnsmasq` del host Linux, operando en la red NAT (`192.168.122.1`), actuaba como un Rogue DHCP. Respondía a las solicitudes de descubrimiento más rápido que el servidor de Windows, entregando su propio DNS.
* **Resolución:** Se aplicó un *override* en las propiedades IPv4 del adaptador de red del cliente, estableciendo estáticamente la IP del Controlador de Dominio (`192.168.122.164`) como "Preferred DNS server". Esto permitió la resolución exitosa y la unión del equipo al dominio manteniendo la salida a internet del hipervisor.

### Incidente 2: Simulación y Cacería de Eventos de Seguridad (Brute Force)
* **Síntoma:** Ataque simulado de fuerza bruta interactiva contra el usuario estándar.
* **Resolución y Monitoreo:** 
  * Se identificó el **Event ID 4625 (Failed Logon - Type 2)** de manera local en el Visor de Eventos del endpoint (Windows 11).
  * Se validó el impacto a nivel de red centralizada cazando el **Event ID 4771 (Kerberos Pre-authentication failed)** directamente en los logs de seguridad del Controlador de Dominio.

## Próximos Pasos (Roadmap)
* [ ] Automatización de creación de usuarios masiva utilizando PowerShell.
* [ ] Implementación de un SIEM (Wazuh) para la centralización y recolección de los logs (Event Forwarding).
