resource "aws_api_gateway_method" "noncompliantapi" {
  authorization = "NONE" # Sensitive
  http_method   = "GET"
}
