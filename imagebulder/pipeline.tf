resource "aws_imagebuilder_image" "example" {
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.dist_config.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.py_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.instance.arn
}

resource "aws_imagebuilder_image_pipeline" "example" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.py_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.instance.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.dist_config.arn
  name                             = "Python-pipeline"
}