# Resultados del laboratorio

Ejecutado el 2026-11-26 en `us-east-1` desde AWS CloudShell. El ID de la cuenta aparece enmascarado (`9560****7678`).

## Recursos creados

| Recurso | Nombre / ID |
| --- | --- |
| Bucket S3 (privado) | `tecsup-class-arturo-20261125` |
| Política IAM | `s3-bucket-access` |
| Rol IAM (trusted entity EC2) | `ec2-s3-bucket-role` |
| Instance profile | `ec2-s3-bucket-role` |
| Instancia EC2 | `i-011f75c0501983c5a` · Amazon Linux 2023 · `t3.micro` |

### Bucket privado

```text
$ aws s3api get-public-access-block --bucket tecsup-class-arturo-20261125
"BlockPublicAcls": true, "IgnorePublicAcls": true,
"BlockPublicPolicy": true, "RestrictPublicBuckets": true
```

### Política asociada al rol

```text
$ aws iam list-attached-role-policies --role-name ec2-s3-bucket-role
"PolicyName": "s3-bucket-access"
```

### Instancia con el rol

```text
|  t3.micro                                                       |
|  running                                                        |
|  arn:aws:iam::9560****7678:instance-profile/ec2-s3-bucket-role  |
```

## Pruebas dentro de la EC2

```text
[ec2-user@ip-172-31-21-125 ~]$ aws sts get-caller-identity
{
    "UserId": "AROA55F6KABHBPUW3RBBN:i-011f75c0501983c5a",
    "Account": "9560****7678",
    "Arn": "arn:aws:sts::9560****7678:assumed-role/ec2-s3-bucket-role/i-011f75c0501983c5a"
}

[ec2-user@ip-172-31-21-125 ~]$ aws s3 ls s3://tecsup-class-arturo-20261125
2026-11-26 01:33:08          5 prueba.txt

[ec2-user@ip-172-31-21-125 ~]$ aws s3 ls
aws: [ERROR]: An error occurred (AccessDenied) when calling the ListBuckets operation:
User: arn:aws:sts::9560****7678:assumed-role/ec2-s3-bucket-role/i-011f75c0501983c5a
is not authorized to perform: s3:ListAllMyBuckets because no identity-based policy
allows the s3:ListAllMyBuckets action
```

| Prueba | Esperado | Obtenido |
| --- | --- | --- |
| `aws sts get-caller-identity` | Rol asumido | ✅ `assumed-role/ec2-s3-bucket-role` |
| `aws s3 ls s3://$BUCKET` | Objetos del bucket | ✅ `prueba.txt` |
| `aws s3 ls` | AccessDenied | ✅ `AccessDenied` (`s3:ListAllMyBuckets` no concedido) |

**Conclusión:** la EC2 obtiene credenciales temporales del rol (sin access keys en el servidor) y solo puede operar sobre su propio bucket: mínimo privilegio.
