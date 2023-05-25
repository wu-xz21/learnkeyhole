from __future__ import print_function
import distutils.spawn
import sys
sys.path
sys.path.append('src/learnkeyhole/__main__.py')


from setuptools import setup, find_packages

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()


setup(
    packages=find_packages(),

        package_data = {
        # 如果包中含有.txt文件，则包含它
        '': ['*.txt'],
        '': ['*.ui'],
        },
    entry_points={
        'console_scripts':[
            'learnkeyhole = learnkeyhole.__main__:main'
        ]
    },
    long_description=long_description,
    long_description_content_type='text/markdown'
    
      )
