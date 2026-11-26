# Paso 2: política de mínimo privilegio, solo sobre el bucket del laboratorio.
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid       = "ListarSoloMiBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.lab.arn] # el bucket
  }

  statement {
    sid       = "LeerEscribirBorrarObjetosDeMiBucket"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.lab.arn}/*"] # los objetos dentro del bucket
  }
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.name}-bucket-access"
  description = "ListBucket + Get/Put/DeleteObject solo sobre ${aws_s3_bucket.lab.bucket}"
  policy      = data.aws_iam_policy_document.s3_access.json
}

# Paso 3: rol con trusted entity EC2.
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# La EC2 no recibe el rol directamente, sino un instance profile que lo contiene.
resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}
