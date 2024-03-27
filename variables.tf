// ========================== storage account variables ==========================
variable "storage_is_hns_enabled" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = false
  type        = bool
}
variable "storage_ip_rules" {
  description = "Specifies IP rules for the storage account"
  default     = []
  type        = list(string)
}
variable "pe_blob_subresource_names" {
  description = "(Optional) Specifies a subresource names which the Private Endpoint is able to connect to Blob."
  default     = ["blob"]
  type        = list(string)
}
variable "pe_blob_private_dns_zone_group_name" {
  description = "(Required) Specifies the Name of the Private DNS Zone Group for Blob. "
  default     = "BlobPrivateDnsZoneGroup"
  type        = string
}