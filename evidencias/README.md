# Evidencias

Salidas reales de `terraform apply` y de las pruebas en la EC2: [resultados.md](resultados.md).

Capturas opcionales (tapar el ID de la cuenta antes de subirlas):

1. `01-terraform-apply.png` — `Apply complete! Resources: 10 added`
2. `02-bucket.png` — bucket privado en la consola de S3
3. `03-role.png` — rol con la política y trusted entity EC2
4. `04-ec2.png` — instancia con el IAM role asociado
5. `05-pruebas.png` — rol asumido, objetos del bucket y `AccessDenied`
