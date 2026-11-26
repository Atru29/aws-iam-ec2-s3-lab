# Paso 1: bucket S3 privado tecsup-class-<id-único>.

resource "random_id" "bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "lab" {
  bucket = "tecsup-class-${random_id.bucket.hex}"

  # Permite que `terraform destroy` borre el bucket aunque tenga objetos.
  force_destroy = true
}

# Privado: bloquea cualquier acceso público.
resource "aws_s3_bucket_public_access_block" "lab" {
  bucket = aws_s3_bucket.lab.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Un objeto inicial para que `aws s3 ls s3://$BUCKET` muestre algo.
resource "aws_s3_object" "prueba" {
  bucket  = aws_s3_bucket.lab.id
  key     = "prueba.txt"
  content = "Hola desde Terraform\n"
}
