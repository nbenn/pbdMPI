\name{Utility execmpi}
\alias{execmpi}
\title{ Execute MPI code in system }
\description{
  This function basically saves code in a spmd.file and executes
  MPI via R's system call e.g.
  \code{system("mpiexec -np 2 Rscript spmd.file")}.
}
\usage{
execmpi(spmd.code = NULL, spmd.file = NULL,
    mpicmd = NULL, nranks = 2L, verbose = TRUE)
}
\arguments{
  \item{spmd.code}{SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{spmd.file}{a file contains SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{mpicmd}{MPI executable command. If \code{NULL}, system default will be searched.}
  \item{nranks}{number of processes to run the SPMD code envoked by mpicmd.}
  \item{verbose}{print SPMD code outputs and MPI messages.}
}
\details{
  When the \code{spmd.code} is \code{NULL}: The code should be already
  saved in the file named \code{spmd.file} for using.

  When the \code{spmd.code} is not \code{NULL}:
  The \code{spmd.code} will be dumped to a temp file (\code{spmd.file}) via the
  call \code{writeLines(spmd.code, conn)} where
  \code{conn <- file(spmd.file, open = "wt")}. The file will be closed after
  the dumping.

  When \code{spmd.file} is ready (either dumped from \code{spmd.code} or
  provided by the user), the steps below will be followed:
  If \code{spmd.file = NULL}, then a temporary file will be generated and
  used to dump \code{spmd.code}.

  For Unix-alike systems, the command
  \code{cmd <- paste(mpicmd, "-np", nranks, "Rscript", spmd.file, ">", log.file, " 2>&1 & echo \"PID=$!\" &")}
  is executed via \code{system(cmd, intern = TRUE, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)}. The \code{log.file} is a temporary file to
  save the outputs from the \code{spmd.code}. The results saved to the
  \code{log.file} will be read back in and \code{cat} and \code{return}
  to R.

  For Windows, the \code{cmd} will be
  \code{paste(mpicmd, "-np", nranks, "Rscript", spmd.file)}
  and is executed via
  \code{system(cmd, intern = TRUE, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)}.
}
\value{
  Basically, only the PID of the MPI job (in background) will be returned
  in Linux-alike systems. For Windows, the MPI job is always wait until
  it is complete.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com} and Drew Schmidt.
}
\seealso{
  \code{pbdCS::pbdRscript()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(1)
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)

spmd.file <- tempfile()
cat("
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(2)
finalize()
", file = spmd.file)
pbdMPI::execmpi(spmd.file = spmd.file, nranks = 2L)
%}
}
\keyword{utility}
