"""Install pypi deps."""

load("@mypy_pypi//:requirements.bzl", "install_deps")

def install():
    """Install pypi deps."""

    install_deps()
