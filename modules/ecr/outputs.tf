output "repo_url" {
  value = aws_ecr_repository.ecr-repo.repository_url
}

output "repo_arn" {
  value = aws_ecr_repository.ecr-repo.arn
}

output "registry_id" {
  value = aws_ecr_repository.ecr-repo.registry_id
}