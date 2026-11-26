# Laboratorio IAM + EC2 + S3

Una instancia EC2 accede a **un solo bucket S3** mediante un **rol IAM**, sin guardar access keys en el servidor. Cualquier acción fuera de ese bucket se deniega (mínimo privilegio).

```text
EC2 (Amazon Linux 2023)
  └─ Instance profile ─► Rol ec2-s3-bucket-role ─► Política s3-bucket-access
                                                     ├─ s3:ListBucket            → solo mi bucket
                                                     └─ s3:Get/Put/DeleteObject  → solo objetos de mi bucket
                                                          │
                                                          ▼
                                                 S3: tecsup-class-arturo-20261125 (privado)
```

| Archivo | Contenido |
| --- | --- |
| `iam/s3-bucket-access-policy.json` | Política IAM: permisos solo sobre el bucket propio |
| `iam/ec2-trust-policy.json` | Trusted entity del rol: el servicio EC2 puede asumirlo |
| `scripts/pruebas-ec2.sh` | Pruebas que se ejecutan dentro de la EC2 |
| `evidencias/` | Capturas de cada paso |

## Pasos en la consola de AWS

1. **Bucket S3** — S3 → *Create bucket*: `tecsup-class-arturo-20261125`, *Block all public access* activado (privado).
2. **Política IAM** — IAM → *Policies* → *Create policy* → pestaña JSON → pegar `iam/s3-bucket-access-policy.json` → nombre `s3-bucket-access`.
3. **Rol IAM** — IAM → *Roles* → *Create role* → *AWS service* → **EC2** → adjuntar `s3-bucket-access` → nombre `ec2-s3-bucket-role`. (La consola genera la trust policy de `iam/ec2-trust-policy.json`.)
4. **Instancia EC2** — EC2 → *Launch instance*: Amazon Linux 2023, `t3.micro`; en *Advanced details* → *IAM instance profile* elegir `ec2-s3-bucket-role`.
5. **Demostrar permisos** — conectarse con *EC2 Instance Connect* y ejecutar las pruebas.

## Pruebas en la EC2

| Comando | Resultado esperado | Por qué |
| --- | --- | --- |
| `aws sts get-caller-identity` | ✅ `assumed-role/ec2-s3-bucket-role/i-...` | La CLI usa las credenciales temporales del rol |
| `aws s3 ls s3://$BUCKET` | ✅ Objetos del bucket | La política permite `s3:ListBucket` en ese bucket |
| `aws s3 ls` | ❌ `AccessDenied` | Listar todos los buckets requiere `s3:ListAllMyBuckets`, que no se concedió |

```bash
BUCKET=tecsup-class-arturo-20261125 bash pruebas-ec2.sh
```

## Limpieza (para no generar costos)

Terminar la instancia EC2 → vaciar y borrar el bucket → borrar el rol y la política.
