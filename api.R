#* @apiTitle Mostrar informações segundo ID

#* @param input
#* @get /info
function(input) {
  # Ler variáveis de ambiente
  readRenviron(".Renviron")

  s3_region <- Sys.getenv("S3_REGION")
  s3_endpoint <- Sys.getenv("S3_ENDPOINT")
  s3_access_key_id <- Sys.getenv("S3_ACCESS_KEY_ID")
  s3_secret_access_key <- Sys.getenv("S3_SECRET_ACCESS_KEY")

  # Criar conexão com o banco
  con <- duckdb::dbConnect(duckdb::duckdb(), ":memory:")
  invisible(DBI::dbExecute(con, "INSTALL httpfs;"))
  invisible(DBI::dbExecute(con, "LOAD httpfs;"))
  invisible(DBI::dbExecute(
    con,
    glue::glue("SET s3_region='{s3_region}';")
  ))
  invisible(DBI::dbExecute(
    con,
    glue::glue("SET s3_endpoint='{s3_endpoint}';")
  ))
  invisible(DBI::dbExecute(
    con,
    glue::glue("SET s3_access_key_id='{s3_access_key_id}';")
  ))
  invisible(DBI::dbExecute(
    con,
    glue::glue("SET s3_secret_access_key='{s3_secret_access_key}';")
  ))

  # Consulta
  resposta <- dplyr::tbl(con, "s3://duckdb-ser/nyc-taxi.parquet") |>
    dplyr::filter(id == input) |>
    dplyr::as_tibble() |>
    as.data.frame()

  duckdb::dbDisconnect(con, shutdown = TRUE)

  # Resultado
  return(resposta)
}
