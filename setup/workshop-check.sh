#!/bin/bash
# Workshop Environment Verification Script
# Run this to verify your setup is ready for the CWL workshop

set -e

echo "=========================================="
echo "CWL Workshop - Environment Check"
echo "=========================================="
echo ""

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo "  ✅ $1"
    ((PASS++))
}

check_fail() {
    echo "  ❌ $1"
    ((FAIL++))
}

check_warn() {
    echo "  ⚠️  $1"
    ((WARN++))
}

# Check if running in a virtual environment
echo "Checking Python environment..."
if [[ -n "$VIRTUAL_ENV" ]]; then
    check_pass "Running in virtual environment: $VIRTUAL_ENV"
elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    check_pass "Running in conda environment: $CONDA_DEFAULT_ENV"
else
    check_warn "Not running in a virtual environment"
    echo "        Recommended: Create one with 'python3 -m venv cwl-workshop-env'"
    echo "        Then activate with 'source cwl-workshop-env/bin/activate'"
fi

echo ""

# Check Docker
echo "Checking Docker..."
if command -v docker &> /dev/null; then
    check_pass "Docker is installed"
    
    if docker info &> /dev/null; then
        check_pass "Docker daemon is running"
        
        # Check Docker memory
        DOCKER_MEM=$(docker info 2>/dev/null | grep "Total Memory" | awk '{print $3}' | sed 's/GiB//')
        if [ -n "$DOCKER_MEM" ]; then
            if (( $(echo "$DOCKER_MEM >= 4" | bc -l) )); then
                check_pass "Docker has ${DOCKER_MEM}GB RAM (≥4GB required)"
            else
                check_warn "Docker has ${DOCKER_MEM}GB RAM (4GB+ recommended)"
            fi
        fi
        
        # Test Docker
        if docker run --rm hello-world &> /dev/null; then
            check_pass "Docker can run containers"
        else
            check_fail "Docker cannot run containers"
        fi
    else
        check_fail "Docker daemon is not running"
        echo "        Start Docker Desktop or run: sudo systemctl start docker"
    fi
else
    check_fail "Docker is not installed"
    echo "        Install from: https://docs.docker.com/get-docker/"
fi

echo ""

# Check cwltool
echo "Checking CWL tools..."
if command -v cwltool &> /dev/null; then
    CWLTOOL_VERSION=$(cwltool --version 2>&1 | head -1)
    check_pass "cwltool is installed ($CWLTOOL_VERSION)"
else
    check_fail "cwltool is not installed"
    if [[ -n "$VIRTUAL_ENV" ]] || [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        echo "        Install with: pip install cwltool"
    else
        echo "        Create a virtual environment first:"
        echo "          python3 -m venv cwl-workshop-env"
        echo "          source cwl-workshop-env/bin/activate"
        echo "          pip install cwltool"
    fi
fi

echo ""

# Check Python
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    check_pass "Python3 is installed ($PYTHON_VERSION)"
    
    # Check for key packages
    if python3 -c "import yaml" 2>/dev/null; then
        check_pass "PyYAML is installed"
    else
        check_warn "PyYAML not found (pip install pyyaml)"
    fi
else
    check_fail "Python3 is not installed"
fi

echo ""

# Check Git
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    check_pass "Git is installed ($GIT_VERSION)"
else
    check_warn "Git is not installed (optional but recommended)"
fi

echo ""

# Check text editor
echo "Checking text editors..."
if command -v code &> /dev/null; then
    check_pass "VS Code is installed (recommended)"
elif command -v vim &> /dev/null; then
    check_pass "vim is available"
elif command -v nano &> /dev/null; then
    check_pass "nano is available"
else
    check_warn "No common text editor found"
fi

echo ""

# Check disk space
echo "Checking disk space..."
AVAILABLE_SPACE=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//')
if [ -n "$AVAILABLE_SPACE" ] && [ "$AVAILABLE_SPACE" -ge 10 ]; then
    check_pass "Sufficient disk space available (${AVAILABLE_SPACE}GB)"
elif [ -n "$AVAILABLE_SPACE" ]; then
    check_warn "Limited disk space (${AVAILABLE_SPACE}GB, 10GB+ recommended)"
fi

echo ""

# Check RAM
echo "Checking system memory..."
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEM" -ge 8 ]; then
        check_pass "System has ${TOTAL_MEM}GB RAM"
    else
        check_warn "System has ${TOTAL_MEM}GB RAM (8GB+ recommended)"
    fi
elif [ -f /proc/meminfo ]; then
    TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024/1024)}')
    if [ "$TOTAL_MEM" -ge 8 ]; then
        check_pass "System has ${TOTAL_MEM}GB RAM"
    else
        check_warn "System has ${TOTAL_MEM}GB RAM (8GB+ recommended)"
    fi
fi

echo ""

# Check workshop Docker image
echo "Checking workshop Docker image..."
if docker images | grep -q "astronomy-tools"; then
    check_pass "Workshop Docker image is available"
else
    echo "  ℹ️  Workshop Docker image not found locally"
    echo "      Build it with: docker build -t astronomy-tools:latest docker/astronomy-tools/"
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "  ✅ Passed: $PASS"
echo "  ⚠️  Warnings: $WARN"
echo "  ❌ Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 Your environment is ready for the workshop!"
    exit 0
else
    echo "⚠️  Please fix the failed checks before the workshop."
    echo "   See README.md for installation instructions."
    exit 1
fi
