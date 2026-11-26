# Laboratorio IAM + EC2 + S3 con Terraform

Una instancia EC2 accede a **un solo bucket S3** mediante un **rol IAM**, sin access keys en el servidor. Cualquier acción fuera de ese bucket se deniega (mínimo privilegio). Toda la infraestructura se crea con **Terraform**.

```text
EC2 lab-iam-s3 (Amazon Linux 2023, t3.micro)
  └─ Instance profile ─► Rol lab-iam-s3-ec2-role ─► Política lab-iam-s3-bucket-access
                         (trusted entity: EC2)        ├─ s3:ListBucket            → solo el bucket
                                                      └─ s3:Get/Put/DeleteObject  → solo sus objetos
                                                           │
                                                           ▼
                                              S3 tecsup-class-<id-único> (privado)
```

| Archivo | Paso | Contenido |
| --- | --- | --- |
| `s3.tf` | 1 | Bucket `tecsup-class-<random_id>`, bloqueo de acceso público y un objeto `prueba.txt` |
| `iam.tf` | 2 y 3 | Política (ListBucket + Get/Put/DeleteObject sobre el bucket), rol con trusted entity EC2 e instance profile |
| `ec2.tf` | 4 | EC2 Amazon Linux 2023 `t3.micro` con el instance profile; Security Group para EC2 Instance Connect |
| `outputs.tf` | 5 | Nombre del bucket, IDs, comando para conectarse y comandos de prueba |
| `scripts/pruebas-ec2.sh` | 5 | Pruebas completas para ejecutar dentro de la EC2 |

## Uso

```bash
aws login --region us-east-1                       # sesión temporal, sin access keys
eval "$(aws configure export-credentials --format env)"
terraform init
terraform apply
```

## Pruebas en la EC2 (paso 5)

```bash
$(terraform output -raw connect_command)   # entra a la EC2 con EC2 Instance Connect
terraform output -raw test_commands         # comandos a pegar dentro
```

| Comando | Resultado esperado | Por qué |
| --- | --- | --- |
| `aws sts get-caller-identity` | ✅ `assumed-role/lab-iam-s3-ec2-role/i-...` | La CLI usa las credenciales temporales del rol |
| `aws s3 ls s3://$BUCKET` | ✅ `prueba.txt` | La política permite `s3:ListBucket` en ese bucket |
| `aws s3 ls` | ❌ `AccessDenied` | Listar todos los buckets requiere `s3:ListAllMyBuckets`, que no se concedió |

Resultados reales: [evidencias/resultados.md](evidencias/resultados.md).

## Limpieza

```bash
terraform destroy
```

Borra la EC2, el Security Group, el rol, la política, el instance profile y el bucket (con su contenido).
