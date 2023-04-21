
#根据Python的版本选择抖音云语言基础镜像
FROM public-cn-beijing.cr.volces.com/public/python:uwsgi-python3.9

# 指定构建过程中的工作目录
WORKDIR /opt/application
# 将当前目录(dockerfile所在目录)下所有文件都拷贝到工作目录下（.dockerignore中文件除外)
COPY . /opt/application/project
RUN num=$(grep -n 'project=' /opt/application/project/uwsgi.ini | awk -F ":" '{print $1}') && name=$(sed -n ${num}p /opt/application/project/uwsgi.ini | awk -F "=" '{print $2}') && mv project $name


# 利用 pip 安装依赖
RUN name=$(ls) && pip install --upgrade pip && pip install -r /opt/application/$name/requirements.txt -i https://pypi.mirrors.ustc.edu.cn/simple --trusted-host=pypi.mirrors.ustc.edu.cn/simple

# 写入run.sh
RUN name=$(ls) && echo '#!/usr/bin/env bash\n
#1.生成数据库迁移文件\n
python3 /opt/application/'"${name}"'/manage.py makemigrations&& \n
#2.根据数据库迁移文件来修改数据库\n\
python3 /opt/application/'"${name}"'/manage.py migrate&& \n
#3.用uwsgi启动django服务\n
uwsgi --ini /opt/application/'"${name}"'/uwsgi.ini' > /opt/application/run.sh
RUN chmod a+x /opt/application/run.sh
