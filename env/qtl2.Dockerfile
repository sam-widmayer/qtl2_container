FROM rocker/r-ver:4.0.0
LABEL Sam Widmayer <sjwidmay@gmail.com>

RUN Rscript -e "install.packages('parallel', repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('remotes', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('Rcpp', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "remotes::install_github('rqtl/qtl2')"
RUN Rscript -e "install.packages('qtl2convert', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('qtl2fst', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('qtl2ggplot', dependencies=TRUE, repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages('furrr', dependencies=TRUE, repos='http://cran.us.r-project.org')"
