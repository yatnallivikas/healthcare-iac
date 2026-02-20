output "patient_repo_url" {
  value = aws_ecr_repository.patient.repository_url
}

output "appointment_repo_url" {
  value = aws_ecr_repository.appointment.repository_url
}