# Get Route 53 hosted zone
data "aws_route53_zone" "sctp_zone" {
 name = "sctp-sandbox.com"
}

# Create Route 53 record to point to ALB
resource "aws_route53_record" "website_alias" {
  zone_id = data.aws_route53_zone.sctp_zone.zone_id
  name    = "wstfs3.sctp-sandbox.com"
  type    = "A"

  alias {
    name                   = aws_lb.my_alb.dns_name
    zone_id                = aws_lb.my_alb.zone_id
    evaluate_target_health = true
  }
}


# # *** Create Route 53 record to S3 Static web bucket***

# resource "aws_route53_record" "www" {
#  zone_id = data.aws_route53_zone.sctp_zone.zone_id        # Zone ID of hosted zone: sctp-sandbox.com             
#  name = "${var.name_prefix}"                              # Bucket prefix before sctp-sandbox.com   
#  type = "A"

#  alias {
#    name = aws_s3_bucket_website_configuration.website.website_domain   # S3 website configuration attribute: website_domain
#    zone_id = aws_s3_bucket.static_web_bucket.hosted_zone_id            # Hosted zone of the S3 bucket, Attribute: hosted_zone_id
#    evaluate_target_health = true
#  }
# }



# # ***This automates DNS validation using Route 53***

# # Validate the Certificate Using Route 53.
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



