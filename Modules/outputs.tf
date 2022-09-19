output "public_ip" {
  value = azurerm_public_ip.rg
}
output "private_key" {
  value     = tls_private_key.sshkey.private_key_pem
  sensitive = true
}
