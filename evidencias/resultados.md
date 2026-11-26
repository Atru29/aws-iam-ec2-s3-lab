# Resultados del laboratorio (Terraform)

Ejecutado el 2026-11-26 en `us-east-1`. El ID de la cuenta aparece enmascarado (`9560****7678`).

## Pasos 1 a 4 · `terraform apply`

```text
random_id.bucket: Creation complete after 0s [id=xchVHg]
aws_iam_role.ec2: Creation complete after 1s [id=lab-iam-s3-ec2-role]
aws_s3_bucket.lab: Creation complete after 1s [id=tecsup-class-c5c8551e]
aws_security_group.ssh: Creation complete after 2s [id=sg-02281be4f201443df]
aws_s3_bucket_public_access_block.lab: Creation complete after 1s [id=tecsup-class-c5c8551e]
aws_iam_policy.s3_access: Creation complete after 0s [id=arn:aws:iam::9560****7678:policy/lab-iam-s3-bucket-access]
aws_s3_object.prueba: Creation complete after 1s [id=tecsup-class-c5c8551e/prueba.txt]
aws_iam_role_policy_attachment.s3_access: Creation complete after 1s
aws_iam_instance_profile.ec2: Creation complete after 4s [id=lab-iam-s3-ec2-role]
aws_instance.lab: Creation complete after 16s [id=i-0dc96aacf7249910b]
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
```

| Paso | Recurso |
| --- | --- |
| 1. Bucket privado | `tecsup-class-c5c8551e` con los 4 bloqueos de acceso público |
| 2. Política | `lab-iam-s3-bucket-access` |
| 3. Rol (trusted entity EC2) | `lab-iam-s3-ec2-role` + instance profile |
| 4. EC2 | `i-0dc96aacf7249910b` · Amazon Linux 2023 · `t3.micro` · rol asociado |

## Paso 5 · Pruebas dentro de la EC2

```text
== aws sts get-caller-identity
{
    "UserId": "AROA55F6KABHMYCXNSXZD:i-0dc96aacf7249910b",
    "Account": "9560****7678",
    "Arn": "arn:aws:sts::9560****7678:assumed-role/lab-iam-s3-ec2-role/i-0dc96aacf7249910b"
}

== aws s3 ls s3://tecsup-class-c5c8551e
2026-11-26 02:17:15         21 prueba.txt

== aws s3 ls
aws: [ERROR]: An error occurred (AccessDenied) when calling the ListBuckets operation:
User: arn:aws:sts::9560****7678:assumed-role/lab-iam-s3-ec2-role/i-0dc96aacf7249910b
is not authorized to perform: s3:ListAllMyBuckets because no identity-based policy
allows the s3:ListAllMyBuckets action

== extra: subir y borrar un objeto (PutObject/DeleteObject)
upload: ./p2.txt to s3://tecsup-class-c5c8551e/p2.txt
delete: s3://tecsup-class-c5c8551e/p2.txt
```

| Prueba | Esperado | Obtenido |
| --- | --- | --- |
| `aws sts get-caller-identity` | Rol asumido | ✅ `assumed-role/lab-iam-s3-ec2-role` |
| `aws s3 ls s3://$BUCKET` | Objetos del bucket | ✅ `prueba.txt` |
| `aws s3 ls` | AccessDenied | ✅ `AccessDenied` (`s3:ListAllMyBuckets` no concedido) |
| `aws s3 cp` / `aws s3 rm` | Permitidos | ✅ PutObject y DeleteObject funcionan |

**Conclusión:** la EC2 obtiene credenciales temporales del rol (sin access keys en el servidor) y solo puede operar sobre su propio bucket: mínimo privilegio.
