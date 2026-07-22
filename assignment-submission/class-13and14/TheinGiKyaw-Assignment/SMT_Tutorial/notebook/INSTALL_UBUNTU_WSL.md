# SMT Tutorial Notebook Setup on Ubuntu WSL

These steps install the Python packages needed to open and run the notebooks in this folder on Ubuntu under Windows Subsystem for Linux (WSL).

The notebooks also use external SMT command-line tools such as Moses, GIZA++, KenLM, Perl scripts, and related binaries. Those tools are not Python packages and are not installed by `requirements.txt`.

In WSL Ubuntu, try this:

sudo mkdir -p /mnt/d
sudo mount -t drvfs D: /mnt/d

Then check:

ls /mnt/d

After that, try your project path again:

cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/notebook

If mounting fails, check whether Windows drive mounting is disabled:

cat /etc/wsl.conf

You can also restart WSL from PowerShell or CMD on Windows:

wsl --shutdown

Then reopen Ubuntu and check:

ls /mnt

## 1. Open Ubuntu Terminal

Open the Ubuntu app from Windows.

## 2. Go to the Notebook Folder

Copy this command as one complete line:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/notebook
```

If your terminal wraps the text visually, do not press Enter in the middle of the path.

## 3. Install System Packages

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv perl tree
```

## 3.1. Install Moses SMT Build Dependencies

If you want to compile or run the Moses SMT framework used by `SMT-Tutorial-for-AI-Class-1.ipynb`, install these Ubuntu packages:

```bash
sudo apt install -y \
  g++ \
  git \
  subversion \
  automake \
  libtool \
  zlib1g-dev \
  libicu-dev \
  libboost-all-dev \
  libbz2-dev \
  liblzma-dev \
  graphviz \
  imagemagick \
  make \
  cmake \
  libgoogle-perftools-dev \
  autoconf \
  doxygen
```

Older Moses instructions often list `python-dev`. On Ubuntu 22.04, `python-dev` is usually not available because it referred to Python 2. Use Python 3 development headers instead:

```bash
sudo apt install -y python3-dev
```

If an old Moses build script specifically requires Python 2 headers, try:

```bash
sudo apt install -y python2-dev
```

If `python2-dev` is not available on your Ubuntu version, continue with `python3-dev` first and only troubleshoot Python 2 if the Moses build fails with a Python header error.

## 3.2. Install Moses Under `tool/mosesbin/ubuntu-17.04`

Some notebook cells refer to this old path:

```text
/home/ye/tool/mosesbin/ubuntu-17.04/moses
```

The `ubuntu-17.04` name is just a folder name used by the original tutorial environment. You do not need to install Ubuntu 17.04. On your machine, create the same folder structure under your own home directory:

```bash
mkdir -p ~/tool/mosesbin/ubuntu-17.04
cd ~/tool/mosesbin/ubuntu-17.04
```

Download Moses from the official GitHub repository:

```bash
git clone https://github.com/moses-smt/mosesdecoder.git moses
cd moses
```

Build Moses:

```bash
./bjam -j"$(nproc)"
```

After building, check that the Moses binary exists:

```bash
ls ~/tool/mosesbin/ubuntu-17.04/moses/bin/moses
```

If your Moses folder is `/home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder`, check:

```bash
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/bin
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/bin/moses
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/scripts/ems/experiment.perl
```

If `scripts/ems/experiment.perl` exists but `bin/moses` does not, the source code is present but Moses has not been built successfully yet. Run:

```bash
cd /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder
./bjam -j"$(nproc)"
```

Then check again:

```bash
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/bin/moses
```

If the notebook still contains `/home/ye/...`, replace it with your actual home path. Check your home path with:

```bash
echo $HOME
```

For example, if your Ubuntu username is `gi`, use:

```text
/home/gi/tool/mosesbin/ubuntu-17.04/moses
```

If your teacher provides a prebuilt `ubuntu-17.04.tgz`, store it in `~/tool/mosesbin`, then extract it:

```bash
mkdir -p ~/tool/mosesbin
cp /path/to/ubuntu-17.04.tgz ~/tool/mosesbin/
cd ~/tool/mosesbin
tar -xzf ubuntu-17.04.tgz
```

Then check:

```bash
ls ~/tool/mosesbin/ubuntu-17.04/moses/bin/moses
```

## 3.3. Install GIZA++ Under Ubuntu Home

Do not clone or build GIZA++ inside `/mnt/d`. Windows-mounted folders can cause Git errors such as:

```text
chmod ... .git/config.lock failed: Operation not permitted
fatal: could not set 'core.filemode' to 'false'
```

Clone it inside your Ubuntu home directory:

```bash
mkdir -p ~/tool
cd ~/tool
git clone https://github.com/moses-smt/giza-pp.git
cd giza-pp
make
```

After building, check for the binaries:

```bash
find ~/tool/giza-pp -type f \( -name GIZA++ -o -name mkcls \)
```

Moses needs `mkcls`, `GIZA++`, and `snt2cooc.out`/`snt2cooc` in one external binary directory. Create a combined directory:

```bash
mkdir -p /home/gi/tool/giza-pp/bin-smt

ln -sf /home/gi/tool/giza-pp/GIZA++-v2/GIZA++ /home/gi/tool/giza-pp/bin-smt/GIZA++
ln -sf /home/gi/tool/giza-pp/GIZA++-v2/snt2cooc.out /home/gi/tool/giza-pp/bin-smt/snt2cooc.out
ln -sf /home/gi/tool/giza-pp/mkcls-v2/mkcls /home/gi/tool/giza-pp/bin-smt/mkcls
```

Check:

```bash
ls -l /home/gi/tool/giza-pp/bin-smt
```

The Moses config in the notebooks should use:

```text
external-bin-dir = /home/gi/tool/giza-pp/bin-smt
```

## 3.4. Install KenLM Under `/home/gi/tools/kenlm`

Install KenLM in your Ubuntu home directory, not under `/mnt/d`:

```bash
mkdir -p /home/gi/tools
cd /home/gi/tools
git clone https://github.com/kpu/kenlm.git
cd kenlm
```

Install build dependencies:

```bash
sudo apt install -y build-essential cmake libboost-all-dev zlib1g-dev libbz2-dev liblzma-dev
```

Build KenLM:

```bash
mkdir -p build
cd build
cmake ..
make -j"$(nproc)"
```

Check the main binaries:

```bash
ls /home/gi/tools/kenlm/build/bin/lmplz
ls /home/gi/tools/kenlm/build/bin/build_binary
ls /home/gi/tools/kenlm/build/bin/query
```

For Moses config files, use:

```text
lmplz = /home/gi/tools/kenlm/build/bin/lmplz
lm-binarizer = /home/gi/tools/kenlm/build/bin/build_binary
lm-query = /home/gi/tools/kenlm/build/bin/query
```

## 4. Create a Virtual Environment

Recommended on WSL: create the virtual environment in your Ubuntu home folder, not inside `/mnt/d`. This avoids common `ensurepip` and filesystem issues on Windows-mounted drives.

```bash
python3 -m venv ~/venvs/smt-tutorial
```

If the `~/venvs` folder does not exist yet:

```bash
mkdir -p ~/venvs
python3 -m venv ~/venvs/smt-tutorial
```

Alternative, if you still want the virtual environment inside the notebook folder:

```bash
python3 -m venv --copies .venv
```

## 5. Activate the Virtual Environment

```bash
source ~/venvs/smt-tutorial/bin/activate
```

After activation, your terminal prompt should show `(.venv)`.

## 6. Install Python Requirements

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

## 7. Register a Jupyter Kernel

```bash
python -m ipykernel install --user --name smt-tutorial --display-name "Python SMT Tutorial"
```

## 8. Start JupyterLab

```bash
jupyter lab
```

When JupyterLab opens, select the kernel named `Python SMT Tutorial`.

## Optional: Check GPU Access

The Jupyter kernel can use a GPU only if:

- Windows has a working NVIDIA GPU driver with WSL support.
- Ubuntu WSL can see the GPU.
- The Python package you use supports GPU execution.

Check whether WSL can see the GPU:

```bash
nvidia-smi
```

If this prints GPU information, WSL can access the NVIDIA GPU.

The default `requirements.txt` for these notebooks does not install GPU libraries because the SMT tutorial notebooks mainly use CPU-based tools such as Python scripts, Perl scripts, Moses, GIZA++, and KenLM.

If you later add notebooks that use PyTorch, install a CUDA-enabled PyTorch build inside the same virtual environment:

```bash
source ~/venvs/smt-tutorial/bin/activate
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

Then test PyTorch GPU access:

```bash
python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU')"
```

If this prints `True` and a GPU name, the `Python SMT Tutorial` kernel can use the GPU through PyTorch.

## Notes

- If `jupyter lab` prints a URL, copy and open that URL in your browser.
- Run `source ~/venvs/smt-tutorial/bin/activate` again whenever you open a new terminal and want to use this environment.
- Moses, GIZA++, KenLM, and other SMT binaries must be installed separately before the full SMT training commands in the notebooks will work.

## Troubleshooting

### `cd: ... class-: No such file or directory`

This happens when the path is accidentally split into two commands:

```bash
cd /mnt/d/.../slide-code/class-13and14/SMT_Tutorial/notebook
```

Run the command as one complete line:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/notebook
```

You can also use tab completion to avoid typing the full path:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/
cd class-13and14/SMT_Tutorial/notebook
```

### `cd: /mnt/d/.../notebook: No such file or directory`

This means the command is now typed correctly, but WSL cannot find the Windows folder at that exact path.

Check whether the `D:` drive is mounted:

```bash
ls /mnt
ls /mnt/d
```

Then walk through the path step by step:

```bash
ls /mnt/d/Job_Requirements
ls /mnt/d/Job_Requirements/PracticalProjectsFromDrYe
ls /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F
ls /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code
```

If the project is not under `/mnt/d`, search for it:

```bash
find /mnt -maxdepth 5 -type d -name AIE-F 2>/dev/null
find ~ -maxdepth 5 -type d -name AIE-F 2>/dev/null
```

After you find the real `AIE-F` folder, go into:

```bash
cd PATH_TO_AIE-F/slide-code/class-13and14/SMT_Tutorial/notebook
```

### `sudo apt update` shows ROS repository errors

Errors like these are from unrelated ROS apt repositories:

```text
EXPKEYSIG F42ED6FBAB17C654 Open Robotics
The repository 'http://packages.ros.org/ros/ubuntu jammy Release' does not have a Release file.
```

For this notebook setup, you can continue if the required packages install successfully.

If you want to stop the ROS errors from appearing, inspect the configured ROS source files:

```bash
ls /etc/apt/sources.list.d/
grep -R "packages.ros.org" /etc/apt/sources.list /etc/apt/sources.list.d/
```

Then disable the old ROS source file by renaming it. Replace the filename below with the actual file shown by the previous command:

```bash
sudo mv /etc/apt/sources.list.d/ros-latest.list /etc/apt/sources.list.d/ros-latest.list.disabled
sudo apt update
```

### `python3 -m venv .venv` fails during `ensurepip`

If you see an error like this:

```text
ensurepip returned non-zero exit status 1
```

Create the virtual environment in your Ubuntu home folder instead:

```bash
mkdir -p ~/venvs
python3 -m venv ~/venvs/smt-tutorial
source ~/venvs/smt-tutorial/bin/activate
```

Then go back to the notebook folder and install the requirements:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/notebook
pip install --upgrade pip
pip install -r requirements.txt
```

If you must create `.venv` inside the `/mnt/d` folder, use:

```bash
python3 -m venv --copies .venv
```

### `./ref2sgm.pl: not found` or `./src2sgm.pl: not found`

In `SMT-Tutorial-for-AI-Class-1.ipynb`, `generate_sgms.pl` runs these scripts with relative paths:

```perl
./ref2sgm.pl
./src2sgm.pl
```

So all three files must be in the current working directory:

```text
generate_sgms.pl
ref2sgm.pl
src2sgm.pl
```

Check your current directory inside the notebook:

```python
%pwd
```

Then check whether the scripts are there:

```python
!ls -l generate_sgms.pl ref2sgm.pl src2sgm.pl
```

For the files included in this repo, go to the scripts folder first:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/clean-data/scripts
!ls -l generate_sgms.pl ref2sgm.pl src2sgm.pl
```

If the files exist but are not executable, run:

```python
!chmod +x generate_sgms.pl ref2sgm.pl src2sgm.pl
```

Another safe fix is to edit `generate_sgms.pl` so it runs the helper scripts through Perl directly:

```perl
`perl ./ref2sgm.pl $lang > test.$lang.ref.sgm`;
`perl ./src2sgm.pl $lang > test.$lang.src.sgm`;
```

Then run:

```python
!perl ./generate_sgms.pl
```

If your repo is not mounted at `/mnt/d`, replace the path with your actual `AIE-F` path.

### `.../pbsmt/data/baseline at ./generate_configs.pl line 39`

This is not a missing package error. It means `generate_configs.pl` found an existing `baseline` output folder and stopped intentionally.

The relevant line is:

```perl
die("$smtpath/$expt") if (-d "$smtpath/$expt");
```

So if this folder already exists:

```text
SMT_Tutorial/pbsmt/data/baseline
```

the script prints that path and exits.

If you want to regenerate the config files and do not need the old `baseline` folder, remove it first:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!rm -rf data/baseline
!perl ./generate_configs.pl
```

If you want to keep the old folder, rename it first:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!mv data/baseline data/baseline_backup
!perl ./generate_configs.pl
```

After successful generation, check:

```python
!tree data/baseline
```

### `baseline/.../steps/1` does not exist

The `steps/1` folder is created by Moses EMS when `run-baseline.pl` successfully starts training. It is not created by `generate_configs.pl`.

If you only see config files like these:

```text
data/baseline/my-rk/config.baseline.my-rk
data/baseline/rk-my/config.baseline.rk-my
```

then config generation worked, but baseline training did not complete.

First, note the language pair names. This repo has:

```text
train.my
train.rk
```

so the generated folders are:

```text
data/baseline/my-rk
data/baseline/rk-my
```

They are not `my-th` or `th-my` unless your data files are `train.my` and `train.th`.

Check the Moses EMS path:

```bash
ls /home/gi/tool/mosesbin/ubuntu-17.04/moses/scripts/ems/experiment.perl
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/moses/scripts/ems/experiment.perl
ls /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/scripts/ems/experiment.perl
```

Use whichever path exists. Then update `run-baseline.pl` and `config.baseline` to match it.

For example, if this exists:

```text
/home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/scripts/ems/experiment.perl
```

then `run-baseline.pl` should call:

```perl
/home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder/scripts/ems/experiment.perl
```

and `config.baseline` should contain:

```text
moses-src-dir = /home/gi/tool/mosesbin/ubuntu-17.04/mosesdecoder
```

After fixing those paths, regenerate the baseline configs and run training:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!rm -rf data/baseline
!perl ./generate_configs.pl
!time perl ./run-baseline.pl
```

Then check:

```python
!tree data/baseline/rk-my/steps | head
```

If `%cd data/baseline/rk-my/steps/1` still fails, do not continue to the later notebook cells yet. Check the training log first:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!tail -n 80 run1.log
```

Also check whether any `steps` folder was created:

```python
!find data/baseline -maxdepth 4 -type d -name steps -o -name 1
```

If `run1.log` says `experiment.perl: not found`, fix the Moses path in `run-baseline.pl`.

If `run1.log` says `mkcls`, `GIZA++`, `snt2cooc.out`, or `plain2snt.out` is not found, fix the GIZA++ path in `config.baseline`, then regenerate configs and rerun `run-baseline.pl`.

### `test.multi-bleu.1: No such file or directory`

This file is created only after Moses EMS reaches the `EVALUATION:test:multi-bleu` step.

If it is missing, check whether earlier steps crashed:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!tail -n 120 run1.log
!find data/baseline -name "*.STDERR" -exec grep -H "ERROR\\|Cannot find\\|crashed" {} \;
```

Common cause: GIZA++ binaries are not in the configured `external-bin-dir`. The error looks like:

```text
ERROR: Cannot find mkcls, GIZA++/mgiza, & snt2cooc.out/snt2cooc
```

Create the combined GIZA++ directory:

```bash
mkdir -p /home/gi/tool/giza-pp/bin-smt
ln -sf /home/gi/tool/giza-pp/GIZA++-v2/GIZA++ /home/gi/tool/giza-pp/bin-smt/GIZA++
ln -sf /home/gi/tool/giza-pp/GIZA++-v2/snt2cooc.out /home/gi/tool/giza-pp/bin-smt/snt2cooc.out
ln -sf /home/gi/tool/giza-pp/mkcls-v2/mkcls /home/gi/tool/giza-pp/bin-smt/mkcls
ls -l /home/gi/tool/giza-pp/bin-smt
```

Make sure `config.baseline` contains:

```text
external-bin-dir = /home/gi/tool/giza-pp/bin-smt
```

Then regenerate from scratch:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!rm -rf data/baseline run1.log
!perl ./generate_configs.pl
!time perl ./run-baseline.pl
```

After the run completes, find the BLEU files:

```python
!find data/baseline -name "test.multi-bleu.1" -print
```

Then `cd` to the printed `evaluation` folder before running:

```python
!cat ./test.multi-bleu.1
```

### `TRAINING:build-ttable crashed` with `chmod: Operation not permitted`

If `test.multi-bleu.1` is still not generated, check:

```python
!find data/baseline -name "TRAINING_build-ttable.1.STDERR" -exec cat {} \;
```

If you see:

```text
chmod: changing permissions of '.../model/tmp.../run.0.sh': Operation not permitted
ERROR: Scoring of phrases failed
```

then Moses is trying to run training from `/mnt/d`, a Windows-mounted drive. Some Linux permission operations fail there, especially `chmod` on generated shell scripts.

Fix: keep the repo/data on `/mnt/d`, but write Moses training output under Linux storage, for example:

```text
/home/gi/smt-work/SMT_Tutorial/pbsmt
```

The files to edit are:

```text
slide-code/class-13and14/SMT_Tutorial/pbsmt/generate_configs.pl
slide-code/class-13and14/SMT_Tutorial/pbsmt/run-baseline.pl
```

Use these settings:

```perl
# generate_configs.pl
my $smtpath = "/home/gi/smt-work/SMT_Tutorial/pbsmt";
my $datapath = "/mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt/data";
```

```perl
# run-baseline.pl
my @configs = `find /home/gi/smt-work/SMT_Tutorial/pbsmt/ -name "config.baseline*" | sort`;
```

Then rerun:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!rm -rf /home/gi/smt-work/SMT_Tutorial/pbsmt run1.log
!mkdir -p /home/gi/smt-work/SMT_Tutorial/pbsmt
!perl ./generate_configs.pl
!time perl ./run-baseline.pl
```

After it finishes:

```python
!find /home/gi/smt-work/SMT_Tutorial/pbsmt -name "test.multi-bleu.1" -print
```

### `/bin/bash^M: bad interpreter`

This means the script has Windows CRLF line endings. Linux sees the first line as `/bin/bash\r` instead of `/bin/bash`.

Fix one script:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
sed -i 's/\r$//' run-pbsmt.sh
chmod +x run-pbsmt.sh
```

Then run:

```bash
./run-pbsmt.sh
```

If many shell or Perl scripts have this problem, install `dos2unix` and convert them:

```bash
sudo apt install -y dos2unix
find . -type f \( -name "*.sh" -o -name "*.pl" \) -exec dos2unix {} \;
```

### `ls: cannot access '*.png': No such file or directory`

In `SMT-Tutorial-for-AI-Class-1.ipynb`, the cell:

```python
!ls *.png
```

is used in the later error-analysis/reporting section. It expects a generated graph image such as:

```text
graph.1.png
```

That PNG is only created after the Moses EMS run reaches the reporting/analysis steps. If baseline training has not completed, or if the notebook is in the wrong current directory, no PNG file will exist yet.

Check your current notebook directory:

```python
%pwd
```

Search for generated PNG files under the PBSMT folder:

```python
!find /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt -name "*.png"
```

If nothing is printed, finish fixing and running:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt
!time perl ./run-baseline.pl
```

The repo also contains example PNGs from the original MTRSS materials:

```bash
find /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/MTRSS -name "*.png"
```

Those can be used only as reference images; they are not generated results from your current run.

### Generate `graph.1.png` from Moses EMS graph files

Moses EMS may create these files before the PNG:

```text
steps/1/graph.1.dot
steps/1/graph.1.ps
```

On Ubuntu 22.04, ImageMagick often blocks PostScript conversion and prints:

```text
convert-im6.q16: attempt to perform an operation not allowed by the security policy `PS'
convert-im6.q16: no images defined `steps/1/graph.1.png'
```

The safer fix is to generate the PNG directly from Graphviz `.dot`:

```bash
sudo apt install -y graphviz
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt/data/baseline/rk-my
dot -Tpng steps/1/graph.1.dot -o steps/1/graph.1.png
ls steps/1/graph.1.png
```

For the other direction:

```bash
cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt/data/baseline/my-rk
dot -Tpng steps/1/graph.1.dot -o steps/1/graph.1.png
ls steps/1/graph.1.png
```

Then in the notebook:

```python
%cd /mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/slide-code/class-13and14/SMT_Tutorial/pbsmt/data/baseline/rk-my/steps/1
!ls *.png
```

/home/ye/tool/mosesbin/ubuntu-17.04/moses

is just a folder name.

Use this instead on your WSL Ubuntu:

mkdir -p ~/tool/mosesbin/ubuntu-17.04
cd ~/tool/mosesbin/ubuntu-17.04
git clone https://github.com/moses-smt/mosesdecoder.git
moses
cd moses
./bjam -j"$(nproc)"

Then check:

ls ~/tool/mosesbin/ubuntu-17.04/moses/bin/moses

If your username is gi, your Moses path will be:

/home/gi/tool/mosesbin/ubuntu-17.04/moses

So in the notebook, replace /home/ye/... with /home/gi/....

That error is because you cloned into /mnt/d/..., a
Windows-mounted drive. Git/build tools often fail there
with chmod/filemode operations.

Clone GIZA++ inside Ubuntu home instead:

mkdir -p ~/tool
cd ~/tool
git clone https://github.com/moses-smt/giza-pp.git
cd giza-pp
make

Then check binaries:

find ~/tool/giza-pp -type f \( -name GIZA++ -o -name mkcls
\)

Use those paths in the Moses config/notebook. For your
user, it will probably be something like:

/home/gi/tool/giza-pp/GIZA++-v2
/home/gi/tool/giza-pp/mkcls-v2
