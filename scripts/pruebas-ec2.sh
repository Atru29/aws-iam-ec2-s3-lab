#!/usr/bin/env bash
# Ejecutar DENTRO de la EC2 (Amazon Linux 2023 ya trae la AWS CLI).
# Uso: BUCKET=tecsup-class-arturo-20261125 bash pruebas-ec2.sh
set -uo pipefail
BUCKET="${BUCKET:?Define BUCKET con el nombre de tu bucket}"

echo "== 1. ¿Quién soy? Debe mostrar el rol asumido (assumed-role/ec2-s3-bucket-role/...)"
aws sts get-caller-identity

echo "== 2. Subir, listar, descargar y borrar un objeto en MI bucket (debe funcionar)"
echo "Hola desde $(hostname) - $(date -u)" > prueba.txt
aws s3 cp prueba.txt "s3://$BUCKET/prueba.txt"
aws s3 ls "s3://$BUCKET"
aws s3 cp "s3://$BUCKET/prueba.txt" descargado.txt && cat descargado.txt

echo "== 3. Listar TODOS los buckets (debe dar AccessDenied: la política no da s3:ListAllMyBuckets)"
aws s3 ls

echo "== 4. Borrar el objeto de prueba (DeleteObject permitido)"
aws s3 rm "s3://$BUCKET/prueba.txt"
rm -f prueba.txt descargado.txt
