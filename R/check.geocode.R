#' Função para extrair nome do path a partir do geocode
#'
#' @param escala Caractere. Escala do filtro: `"municipio`, `"estado"`, `"micro"`, `"meso"`
#' @param sigla Sigla do estado
#' @param nonascii Lógico. Se TRUE retorna nome sem caracteres ascii
#' @param geocode Caractere. Geocode IBGE. Município 6 ou 7 dígitos; microrregião 5 dígitos; mesorregião 4 dígitos; estado 2 dígitos
#'
#' @importFrom utils read.csv
#' @importFrom textclean replace_non_ascii
#'
#' @export
#'
check.geocode <- function(escala,
                          geocode,
                          sigla,
                          nonascii = TRUE) {

  if (escala == "pais") {
    nome <- "/pais/Brasil"
    return(nome)
  }
  #url <- paste0("https://servicodados.ibge.gov.br/api/v1/localidades/municipios")
  #df <- jsonlite::fromJSON(url)
  #df$nome.nonascii <- gsub(" ", "_", textclean::replace_non_ascii(df$nome))
  #df$nome.nonascii <- gsub("'", "", df$nome.nonascii)
  #write.csv(df, "./dados/geocode_ibge.csv", row.names = FALSE)
  df <- geocode_ibge
  #geocode <- as.numeric(geocode)
  municipio.code <- sapply(df$id, function(x) substr(x, start = 1, stop = 6))
  micro.code   <- df$microrregiao.id
  meso.code    <- df$microrregiao.mesorregiao.id
  estado.code  <- df$microrregiao.mesorregiao.UF.id
  estado.sigla <- df$microrregiao.mesorregiao.UF.sigla

  if (escala == "municipio") {
    if (!nchar(geocode) %in% c(6, 7))
      stop("geocode nao bate com escala")
    if (nchar(geocode) == 7)
      geocode <- substr(geocode, start = 1, stop = 6)
    if (geocode %in% municipio.code) {
      id <- which(municipio.code == geocode)
      if (nonascii)
        nome <- paste0("municipios/", estado.sigla[id], "/", df$nome.nonascii[id]) # municipios/SP/Sao_Paulo
      else
        nome <- df$nome[id] # municipios/SP/Sao_Paulo
    } else {
      stop("geocode de municipio invalido")
    }
  }

  if (escala == "micro") {
    if (nchar(geocode) != 5)
      stop("geocode nao bate com escala")
    if (geocode %in% micro.code) {
      id <- which(micro.code == geocode)[1]
      micro.nome <- gsub("'", "",
                         gsub(" ", "_",
                              replace_non_ascii(df$microrregiao.nome[id])))
      nome <- paste0("microrregioes/", estado.sigla[id], "/", micro.nome) #microrregioes/SP/Sao_Paulo
    } else {
      stop("geocode de microrregiao invalido")
    }
  }

  if (escala == "meso") {
    if (nchar(geocode) != 4)
      stop("geocode nao bate com escala")
    if (geocode %in% meso.code) {
      id <- which(meso.code == geocode)[1]
      meso.nome <- gsub("'", "",
                        gsub(" ", "_",
                             replace_non_ascii(df$microrregiao.mesorregiao.nome[id])))
      nome <- paste0("mesorregioes/", estado.sigla[id], "/", meso.nome) #mesorregioes/SP/Metropolitana_de_Sao_Paulo
    } else {
      stop("geocode de mesorregiao invalido")
    }
  }

  if (escala == "estado") {
    if (nchar(geocode) != 2)
      stop("geocode nao bate com escala")
    if (geocode %in% estado.code) {
      id <- which(estado.code == geocode)[1]
      nome <- paste0("estado/", estado.sigla[id])
    } else {
      stop("geocode de estado invalido")
    }
  }

  if (escala == "drs") {
    if (missing(sigla))
      stop("precisa de sigla para escala DRS")
    drs <- read.csv(paste0('./dados/DRS_', sigla, '.csv'))
    if (geocode %in% drs$DRS) {
      id <- which(drs$DRS == geocode)[1]
      if (nonascii)
        nome <- paste0("DRS/", sigla, "/", drs[id, 'DRS.nome.nonascii'])
      else
        nome <- drs[id, 'DRS.nome']
    } else {
      stop("geocode de DRS invalido")
    }
  }

  return(nome)
}

# check.geocode(escala = "municipio", geocode = "3512100")
# check.geocode(escala = "estado", geocode = "21")
# check.geocode(escala = "micro", geocode = "21")
# check.geocode(escala = "micro", geocode = "21008")
# check.geocode(escala = "meso", geocode = "2102")
# check.geocode(escala = "DRS", geocode = "1")
