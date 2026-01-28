# hash:sha256:c9b112f3e66624a69cb708be33c863924c2212d60390363252f0db810ff49f7f
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-askpass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
ARG R_VERSION=4.3.2
ENV R_VERSION=${R_VERSION}

SHELL ["/bin/bash", "-lc"]

# install conda packages
RUN mamba install -y -c conda-forge \
    r-base=${R_VERSION} \
    r-argparse \
    r-amap \
    r-broom \
    r-cffr \
    r-colorspace \
    r-dendextend \
    r-devtools \
    "r-ggplot2 <4.0.0" \
    r-ggrepel \
    r-gridExtra \
    r-matrix \
    r-mgcv \
    r-patchwork \
    r-plotly \
    r-rcolorbrewer \
    r-readr \
    r-rmarkdown \
    r-survival \
    r-upsetr \
    r-viridis \
    bioconductor-annotationdbi \
    bioconductor-annotate \
    bioconductor-complexheatmap \
    bioconductor-delayedarray \
    bioconductor-edger \
    bioconductor-genomicranges \
    bioconductor-keggrest \
    bioconductor-limma \
    bioconductor-s4arrays \
    bioconductor-summarizedexperiment \
    bioconductor-sva \
  && conda clean -afy

# install R package
RUN R -e 'remotes::install_github("CCBR/MOSuite", dependencies = TRUE, upgrade="never")' && \
  R -e "library(MOSuite); devtools::test('/opt2/conda/lib/R/library/MOSuite')" && \
  R -s -e "readr::write_csv(tibble::as_tibble(installed.packages()), '/data2/r-packages.csv')"

# cleanup
RUN apt-get clean && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*