# Evidencias

Salidas reales de la ejecución: [resultados.md](resultados.md).

Guardar aquí las capturas con estos nombres:

1. `01-bucket.png` — bucket creado y privado
2. `02-policy.png` — política `s3-bucket-access` (JSON)
3. `03-role.png` — rol `ec2-s3-bucket-role` con la política y trusted entity EC2
4. `04-ec2.png` — instancia con el IAM role asociado
5. `05-get-caller-identity.png` — rol asumido
6. `06-s3-ls-bucket.png` — objetos del bucket
7. `07-s3-ls-accessdenied.png` — `aws s3 ls` con AccessDenied
