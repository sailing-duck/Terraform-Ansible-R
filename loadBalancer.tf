resource "aws_lb" "lewis_alb" {
    name = "alb-for-R"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.lewis_ec2_sg.id]
    subnets = [aws_subnet.lewis_public_subnet[0].id, aws_subnet.lewis_public_subnet[1].id]

    enable_deletion_protection = false

    tags = {
        Name = "alb-for-R"
    }
}

resource "aws_lb_target_group" "lewis_tg" {
    name = "lewis-tg"
    port = 8787
    protocol = "HTTP"
    vpc_id = aws_vpc.lewis_vpc.id

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        path                = "/"
        protocol            = "HTTP"
        matcher             = "302"
        interval            = 10
    }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lewis_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lewis_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.lewis_tg.arn
  target_id        = aws_instance.ubuntu.id
  port             = 8787
}