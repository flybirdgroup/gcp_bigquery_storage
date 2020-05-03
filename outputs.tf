output "ip" {
    value = "${google_compute_address.vm_static_ip.address}"
}

output "service_account" {
    value = "${google_compute_instance.default.service_account}"
}

output "service_account_bqquery" {
    value = "${google_compute_instance.default.service_account.0.email}"
}