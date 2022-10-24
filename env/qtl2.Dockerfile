FROM continuumio/miniconda
LABEL Sam Widmayer <sjwidmay@gmail.com>

RUN Rscript -e "install.packages('qtl2', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('qtl2convert', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('qtl2fst', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('qtl2ggplot', dependencies=TRUE, repos='http://cran.us.r-project.org')"
