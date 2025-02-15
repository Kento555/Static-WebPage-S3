# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_web_bucket" {
 bucket = "wstfs3.sctp-sandbox.com"
 force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.static_web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
bucket = aws_s3_bucket.static_web_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_web_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.enable_public_access]
}


resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.static_web_bucket.id
    index_document {suffix = "index.html"}
    error_document {key = "error.html"}
    }


resource "null_resource" "clone_git_repo" {
  provisioner "local-exec" {
    command = "rm -rf website_content && git clone https://github.com/cloudacademy/static-website-example.git website_content && aws s3 sync website_content s3://${aws_s3_bucket.static_web_bucket.id} --exclude \"*.MD\" --exclude \".git*\" --delete"
  }
  depends_on = [aws_s3_bucket.static_web_bucket]
}


