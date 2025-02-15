# Request an ACM Certificate
# Request an ACM certificate for wstfs3.sctp-sandbox.com and 
# optionally for the wildcard *.sctp-sandbox.com (useful if you want a wildcard certificate).
resource "aws_acm_certificate" "cert" {
  domain_name               = "wstfs3.sctp-sandbox.com"
  validation_method         = "DNS"
  subject_alternative_names = ["*.wstfs3.sctp-sandbox.com"]

  lifecycle {create_before_destroy = true}
}

# Validate the Certificate Using Route 53
# This automates DNS validation using Route 53.
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   zone_id = data.aws_route53_zone.sctp_zone.zone_id 
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60

#   lifecycle {
#     ignore_changes = [records, name, type]  # Ignore changes to these attribute
#   }
# }

# Create Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_sg.id]
  subnets            = data.aws_subnets.public_subnets.ids
}

# Attach ACM Certificate to an HTTPS Endpoint (via ELB)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, HTTPS!"
      status_code  = "200"
    }
  }
}

