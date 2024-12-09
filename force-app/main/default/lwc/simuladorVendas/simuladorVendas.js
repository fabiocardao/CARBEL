import { LightningElement, track, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getQuoteAndQuoteLineItemData from '@salesforce/apex/SimuladorVendasController.getQuoteAndQuoteLineItemData';
//import getProdutoData from '@salesforce/apex/SimuladorVendasController.getProdutoData';
import getAssetData from '@salesforce/apex/SimuladorVendasController.getAssetData';
import getCustoOperacionalComissao from '@salesforce/apex/SimuladorVendasController.getCustoOperacionalComissao';
import getAgregadosByQuoteLineItemId from '@salesforce/apex/SimuladorVendasController.getAgregadosByQuoteLineItemId';
import salvarSimulacao from '@salesforce/apex/SimuladorVendasController.salvarSimulacao';
import verificaPermissaoCustos from '@salesforce/apex/SimuladorVendasController.verificaPermissaoCustos';


const removeDadoAgragadoCotacao = (lista, dadoRemove) => {
    var arr = new Array();
    lista.forEach(function (dado) {
        if (dado.agregadoId != dadoRemove) {
            arr.push(dado);
        }
    });
    return arr;
}

const validaContemAgregado = (lista, dadoRemove) => {
    var retorno;
    lista.forEach(function (dado) {
        if (dado.agregadoId == dadoRemove) {
            retorno = true;
        }
    });
    return retorno;
}

const agregadosCotacaoConstrutor = (lista) => {
    var arr = new Array();
    lista.forEach(function (dado) {
        arr.push(
            {
                name: dado.AgregadoId__r.Name,
                valor: parseFloat(dado.Custo__c),
                deFabrica: false,
                bonus: false,
                agregadoId: dado.AgregadoId__c,
                itemLinhaCotacaoId: dado.ItemLinhaCotacaoId__c,
                Observacao__c: dado.Observacao__c,
                custoVeiculo: !dado.CobrarCliente__c
            }
        );
    });
    return arr;
}

export default class SimuladorVendas extends NavigationMixin(LightningElement) {

    porcentagemCustoOperacional;
    porcentagemComissaoNf;
    desconto;
    lucroBruto;
    margemLiquida;

    @api recordId;
    @api objectApiName;

    @track cotacao;
    @track itemCotacao;
    @track agregadosCotacao;
    @track utilizarOperacional = false;

    @track voltarOn = false;
    @track salvarOn = false;
    @track cancelarOn = false;
    @track permissaoCuestos = false;

    @track accId = null;
    @track ativoId = null;
    @track productId = null;
    @track oppId = null;

    @track produto = null;
    @track ativo = null;

    @track possuiCotacao = false;

    @track disabledBtn = false;

    @track descontoLike = 'utility:dislike';
    @track descontoVariant = 'error';
    @track lucroBrutoLike = 'utility:dislike';
    @track lucroBrutoVariant = 'error';
    @track margemLiquidaLike = 'utility:dislike';
    @track margemLiquidaVariant = 'error';

    init = true;
    initCustos = true;
    initAsset = true;

    @track camposFormulario = {
        produtoId: null,
        ativoId: null,
        chassi: null,
        marca: null,
        modelo: null,
        anoFabricacao: null,
        motorizacao: null,
        potencia: null,
        placa: null,
        cor: null,
        versao: null,
        anoModelo: null,
        cambio: null,
        combustivel: null,
    };

    @track camposFormularioTabelaVenda = {

        precoPublico: 0,
        totalCustoBruto: 0,
        totalCusto: 0,
        totalCustoDireto: 0,
        totalCustoDiretoComPisCofins: 0,
        totalCustoOperacional: 0,
        totalValorAgregado: 0,
        valorCustoCliente: 0,
        valorTotalComAgregados: 0,
        descontoPorcentagem: 0,
        descontoValor: 0,

        custoDireto: {
            veiculo: 0,
            icmsRetido: 0,
            jurosFloorPlan: 0,
            pisCofins: 0
        },

        custoOperacional: {
            custoOperacao: 0,
            custoComissao: 0
        },

        margemLiquida: 0,
        margemLiquidaValor: 0,

        margemBruta: 0,
        margemBrutaValor: 0,

        agregados: new Array()
    };

    @track agregadosTabelaVenda = {
    };

    @track camposFormularioPropostaCliente = {

        precoPublico: 0,
        estoqueVeiculo: '',
        custoVeiculo: 0,
        totalCusto: 0,
        totalCustoOperacional: 0,
        totalValorAgregado: 0,
        totalCustoBruto: 0,
        totalCustoDireto: 0,
        ICMSVendaAsset: 0,
        pisCofinsAsset: 0,

        custoDireto: {
            veiculo: 0,
            icmsRetido: 0,
            jurosFloorPlan: 0,
            pisCofins: 0
        },

        custoOperacional: {
            custoOperacao: 0,
            custoComissao: 0
        },

        margemLiquida: 0,
        margemLiquidaValor: 0,

        margemBruta: 0,
        margemBrutaValor: 0,

        descontoPorcentagem: 0,
        descontoValor: 0,
        descontoPorcentagemInput: 0,
        descontoValorInput: 0,

        agregadosAtivo: new Array(),
        agregadosCotacao: new Array()
    };

    connectedCallback() {
        
        if ((this.objectApiName == undefined || this.objectApiName == '' || this.objectApiName == null) && this.recordId) {
            this.buscaObjectName (recordId);
        } else {
            this.validaPermissaoCustos();
        }
    }

    renderedCallback() {
        if (this.init && this.objectApiName == 'Quote') {
            this.init = false;
            this.getQuoteAndQuoteLineItem(this.recordId);
        }

        if (this.initAsset && this.objectApiName == 'Asset' && this.recordId) {
            this.initAsset = false;
            this.ativoId = this.recordId;
            this.custoOperacionalComissao(this.recordId, null);
        }
    }

    get vemEstoque () {
        if (this.objectApiName == 'Asset') {
            return true;
        } else {
            return false;
        }
    }

    changeOpportunity(event) {
        this.opportunityId = event.detail.value[0];
    }

    buscaObjectName (recordId) {
        buscaObjectNameById({recordId: recordId})
            .then(result => {
                this.objectApiName = result;
                this.validaPermissaoCustos();
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
            });
    }

    validaPermissaoCustos() {
        verificaPermissaoCustos()
            .then(result => {
                this.permissaoCuestos = result;
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
            });
    }

    getQuoteAndQuoteLineItem(recordId) {
        getQuoteAndQuoteLineItemData({ quoteId: recordId })
            .then(result => {
                this.cotacao = result;
                this.itemCotacao = result.QuoteLineItems[0];
                this.camposFormularioTabelaVenda.descontoPorcentagem = result.QuoteLineItems[0].DescontoPorcentagem__c.toFixed(2);
                this.camposFormularioTabelaVenda.descontoValor = result.QuoteLineItems[0].DescontoReais__c;
                this.camposFormularioPropostaCliente.descontoPorcentagem = result.QuoteLineItems[0].DescontoPorcentagem__c.toFixed(2);
                this.camposFormularioPropostaCliente.descontoValor = result.QuoteLineItems[0].DescontoReais__c;
                this.camposFormularioPropostaCliente.descontoPorcentagemInput = result.QuoteLineItems[0].DescontoPorcentagem__c.toFixed(2);
                this.camposFormularioPropostaCliente.descontoValorInput = result.QuoteLineItems[0].DescontoReais__c;
                this.ativoId = result.QuoteLineItems[0].Ativo__c;
                this.custoOperacionalComissao(result.QuoteLineItems[0].Ativo__c, recordId);
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
                this.onVoltar();
            });
    }
    
    agregadosByQuoteLineItemId(quoteItemId) {
        getAgregadosByQuoteLineItemId({ quoteItemId: quoteItemId })
        .then(result => {
                this.camposFormularioPropostaCliente.agregadosCotacao = agregadosCotacaoConstrutor(result);
                this.agregadosCotacao = agregadosCotacaoConstrutor(result);
                this.valorProposta(this.itemCotacao.Ativo__r.Price, this.itemCotacao.DescontoReais__c);
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
                this.onVoltar();
            });
    }

    custoOperacionalComissao(assetId, quoteId) {
        getCustoOperacionalComissao({assetId: assetId, quoteId: quoteId})
            .then(result => {
                if (result.desconto == undefined || result.comissao == undefined || result.lucroBruto == undefined || result.margemLiquida == undefined) {
                    this.notificationError('Adicione a comissão, desconto, lucro Bruto e margem liquida ao meta dado da Empresa');
                } else {
                    
                    this.porcentagemComissaoNf = result.comissao;
                    this.desconto = result.desconto;
                    this.lucroBruto = result.lucroBruto;
                    this.margemLiquida = result.margemLiquida;
                }
                this.getDadosAtivo(this.ativoId);
                if (this.objectApiName == 'Quote') {
                    this.agregadosByQuoteLineItemId(this.itemCotacao.Id);
                }
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
                this.onVoltar();
            });
    }

    /*changeProduto(event) {

        this.productId = event.detail.value[0];
        this.getDadosProduto(this.productId);
    }

    getDadosProduto(produtoId) {
        getProdutoData({ produtoId: produtoId })
            .then(result => {
                this.produto = result;

                this.camposFormulario.produtoId = result.Id;
                this.camposFormulario.marca = result.MarcaProduto__r.Name;
                this.camposFormulario.anoFabricacao = result.AnoFabricacao__c;
                this.camposFormulario.motorizacao = result.Motorizacao__c;
                this.camposFormulario.potencia = result.Potencia__c;
                this.camposFormulario.anoModelo = result.AnoModelo__c;
                this.camposFormulario.cambio = result.Cambio__c;
                this.camposFormulario.combustivel = result.Combustivel__c;

                this.camposFormularioTabelaVenda.precoPublico = result.PricebookEntries[0].UnitPrice;

                //estes dois valores provavelmente irão ficar no ativo, tem que validar e adiciona-los
                this.camposFormularioTabelaVenda.custoDireto.veiculo = 35000.38;
                this.camposFormularioTabelaVenda.custoDireto.icmsRetido = 5000.57;

                this.camposFormularioTabelaVenda.custoOperacional.custoOperacao = result.PricebookEntries[0].UnitPrice * this.porcentagemCustoOperacional / 100;
                this.camposFormularioTabelaVenda.custoOperacional.custoComissao = result.PricebookEntries[0].UnitPrice * this.porcentagemComissaoNf / 100;

                this.camposFormularioTabelaVenda.totalCustoOperacional = this.camposFormularioTabelaVenda.custoOperacional.custoComissao + this.camposFormularioTabelaVenda.custoOperacional.custoOperacao;

                this.camposFormularioTabelaVenda.totalCustoDireto = this.camposFormularioTabelaVenda.custoDireto.veiculo + this.camposFormularioTabelaVenda.custoDireto.icmsRetido;

                let me = this;
                this.camposFormularioTabelaVenda.totalValorAgregado = 0;
                this.camposFormularioTabelaVenda.agregados.forEach(function (val, index) {
                    me.camposFormularioTabelaVenda.totalValorAgregado = me.camposFormularioTabelaVenda.totalValorAgregado + val.valor;
                })

                this.camposFormularioTabelaVenda.totalCustoBruto = this.camposFormularioTabelaVenda.totalCustoDireto + this.camposFormularioTabelaVenda.totalValorAgregado;
                this.camposFormularioTabelaVenda.totalCusto = this.camposFormularioTabelaVenda.totalCustoBruto + this.camposFormularioTabelaVenda.totalCustoOperacional;


                this.camposFormularioTabelaVenda.margemBrutaValor = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.totalCustoBruto;
                this.camposFormularioTabelaVenda.margemLiquidaValor = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.totalCusto;

                this.camposFormularioTabelaVenda.margemBruta = this.camposFormularioTabelaVenda.margemBrutaValor / this.camposFormularioTabelaVenda.precoPublico;
                this.camposFormularioTabelaVenda.margemLiquida = this.camposFormularioTabelaVenda.margemLiquidaValor / this.camposFormularioTabelaVenda.precoPublico;


            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
            });
    }*/

    getDadosAtivo(assetId) {
        getAssetData({ assetId: assetId })
            .then(result => {
                this.ativo = result.ativo;
                
                this.camposFormulario.ativoId = result.ativo.Id;
                this.camposFormulario.chassi = result.ativo.Chassi__c;
                this.camposFormulario.modelo = result.ativo.Product2.Name;
                this.camposFormulario.placa = result.ativo.Placa__c;
                this.camposFormulario.cor = result.ativo.Cor__c;
                this.camposFormulario.produtoId = result.ativo.Product2Id;
                this.camposFormulario.marca = result.ativo.Marca__c;
                this.camposFormulario.anoFabricacao = result.ativo.AnoFabricacao__c;
                this.camposFormulario.motorizacao = result.ativo.Motorizacao__c;
                this.camposFormulario.potencia = result.ativo.Potencia__c;
                this.camposFormulario.anoModelo = result.ativo.AnoModelo__c;
                this.camposFormulario.cambio = result.ativo.Cambio__c;
                this.camposFormulario.combustivel = result.ativo.Combustivel__c;
                this.porcentagemCustoOperacional = result.ativo.CustoOperacionalPercentual__c ? result.ativo.CustoOperacionalPercentual__c : 0;
                this.camposFormularioTabelaVenda.precoPublico = result.ativo.Price;
                
                //estes dois valores provavelmente irão ficar no ativo, tem que validar e adiciona-los
                this.camposFormularioTabelaVenda.custoDireto.veiculo = result.ativo.CustoVeiculo__c ? result.ativo.CustoVeiculo__c : 0;
                this.camposFormularioTabelaVenda.custoDireto.jurosFloorPlan = result.ativo.JurosFloorPlan__c ? result.ativo.JurosFloorPlan__c : 0;
                
                this.camposFormularioPropostaCliente.estoqueVeiculo = result.ativo.TipoEstoque__c;
                
                this.camposFormularioPropostaCliente.ICMSVendaAsset = result.ativo.ICMSVenda__c;
                this.camposFormularioPropostaCliente.pisCofinsAsset = result.ativo.PisCofins__c;
                
                let lucroFixo = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.custoDireto.veiculo;
                
                if(result.ativo.TipoEstoque__c == 'VU'){
                    
                    this.camposFormularioTabelaVenda.custoDireto.icmsRetido = lucroFixo && result.ativo.ICMSVenda__c ? lucroFixo * result.ativo.ICMSVenda__c / 100 : 0;
                    this.camposFormularioTabelaVenda.custoDireto.pisCofins = result.ativo.PisCofins__c && lucroFixo ? result.ativo.PisCofins__c * lucroFixo / 100 : 0;
                    //estes dois valores provavelmente irão ficar no ativo, tem que validar e adiciona-los
                    
                    this.camposFormularioPropostaCliente.custoDireto.icmsRetido = lucroFixo && result.ativo.ICMSVenda__c ? lucroFixo * result.ativo.ICMSVenda__c / 100 : 0;
                    
                } else {
                    
                    this.camposFormularioTabelaVenda.custoDireto.icmsRetido = result.ativo.CustoVeiculo__c && result.ativo.ICMSVenda__c ? result.ativo.CustoVeiculo__c * result.ativo.ICMSVenda__c / 100 : 0;
                    this.camposFormularioTabelaVenda.custoDireto.pisCofins = result.ativo.PisCofins__c && result.ativo.CustoVeiculo__c ? result.ativo.PisCofins__c * result.ativo.CustoVeiculo__c / 100 : 0;
                    //estes dois valores provavelmente irão ficar no ativo, tem que validar e adiciona-los
                    
                    this.camposFormularioPropostaCliente.custoDireto.icmsRetido = result.ativo.CustoVeiculo__c && result.ativo.ICMSVenda__c ? result.ativo.CustoVeiculo__c * result.ativo.ICMSVenda__c / 100 : 0;
                    
                }
                
                this.camposFormularioPropostaCliente.custoDireto.veiculo = result.ativo.CustoVeiculo__c ? result.ativo.CustoVeiculo__c : 0;
                this.camposFormularioTabelaVenda.custoDireto.jurosFloorPlan = result.ativo.JurosFloorPlan__c ? result.ativo.JurosFloorPlan__c : 0;
                
                this.camposFormularioTabelaVenda.custoOperacional.custoOperacao = result.ativo.Price && result.ativo.CustoOperacionalPercentual__c ? result.ativo.Price * result.ativo.CustoOperacionalPercentual__c / 100 : 0;
                this.camposFormularioTabelaVenda.custoOperacional.custoComissao = result.ativo.Price && this.porcentagemComissaoNf ? result.ativo.Price * this.porcentagemComissaoNf / 100 : 0;
                this.camposFormularioTabelaVenda.totalCustoOperacional = this.camposFormularioTabelaVenda.custoOperacional.custoComissao + this.camposFormularioTabelaVenda.custoOperacional.custoOperacao;

                let lucroFixo2 = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.custoDireto.veiculo - this.camposFormularioTabelaVenda.custoDireto.icmsRetido;
                this.camposFormularioPropostaCliente.custoDireto.pisCofins = result.ativo.PisCofins__c && lucroFixo2 ? result.ativo.PisCofins__c * lucroFixo2 / 100 : 0;
                
                this.camposFormularioTabelaVenda.totalCustoDireto = this.camposFormularioTabelaVenda.custoDireto.veiculo + this.camposFormularioTabelaVenda.custoDireto.icmsRetido + this.camposFormularioPropostaCliente.custoDireto.pisCofins;

                let me = this;
                this.camposFormularioTabelaVenda.totalValorAgregado = 0;
                this.camposFormularioTabelaVenda.agregados = new Array();
                this.camposFormularioPropostaCliente.agregadosAtivo = new Array();
                if (result.agregadoAtivo != undefined && result.agregadoAtivo.length > 0) {
                    result.agregadoAtivo.forEach(function (val, index) {
                        me.camposFormularioTabelaVenda.totalValorAgregado = val.AgregadoId__r.IsBonus__c ? me.camposFormularioTabelaVenda.totalValorAgregado - val.Custo__c : me.camposFormularioTabelaVenda.totalValorAgregado + val.Custo__c;
                        me.camposFormularioTabelaVenda.agregados.push({ agregadoId: val.AgregadoId__c, name: val.AgregadoId__r.Name, valor: val.Custo__c, deFabrica: true, bonus: val.AgregadoId__r.IsBonus__c, custoVeiculo: true});
                        me.camposFormularioPropostaCliente.agregadosAtivo.push({ agregadoId: val.AgregadoId__c, name: val.AgregadoId__r.Name, valor: val.Custo__c, deFabrica: true, bonus: val.AgregadoId__r.IsBonus__c, custoVeiculo: true});
                    })
                }

                this.camposFormularioTabelaVenda.totalCustoBruto = this.camposFormularioTabelaVenda.totalCustoDireto + this.camposFormularioTabelaVenda.totalValorAgregado;
                this.camposFormularioTabelaVenda.totalCusto = this.camposFormularioTabelaVenda.totalCustoBruto + this.camposFormularioTabelaVenda.totalCustoOperacional;

                this.camposFormularioTabelaVenda.margemBrutaValor = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.totalCustoBruto;
                this.camposFormularioTabelaVenda.margemLiquidaValor = this.camposFormularioTabelaVenda.precoPublico - this.camposFormularioTabelaVenda.totalCusto;
                this.camposFormularioTabelaVenda.margemBruta = this.camposFormularioTabelaVenda.precoPublico == 0 ? 0 : this.camposFormularioTabelaVenda.margemBrutaValor / this.camposFormularioTabelaVenda.precoPublico;
                this.camposFormularioTabelaVenda.margemLiquida = this.camposFormularioTabelaVenda.precoPublico == 0 ? 0 : this.camposFormularioTabelaVenda.margemLiquidaValor / this.camposFormularioTabelaVenda.precoPublico;
                
                if (this.objectApiName == 'Quote') {
                    this.valorProposta(this.itemCotacao.Ativo__r.Price, this.itemCotacao.DescontoReais__c);
                } else {
                    this.valorProposta(result.ativo.Price, 0);
                }
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
                this.onVoltar();
            });
    }

    changeUtilizarOperacional (event) {
        this.utilizarOperacional = event.target.checked;
    }
    
    handleValor(event) {
        this.camposFormularioPropostaCliente.valorVeiculo = event.target.value;
        this.camposFormularioPropostaCliente.descontoValorInput = this.ativo.Price - event.target.value;
        this.camposFormularioPropostaCliente.descontoPorcentagemInput = event.target.value == 0 || this.ativo.Price  == 0 ? 0 : (((this.ativo.Price - event.target.value) * 100)/this.ativo.Price).toFixed(2);
    }
    
    handleDescontoReaisChange(event) {
        this.camposFormularioPropostaCliente.descontoValorInput = event.target.value;
        this.camposFormularioPropostaCliente.descontoPorcentagemInput = event.target.value == 0 || this.ativo.Price  == 0 ? 0 : ((event.target.value * 100)/this.ativo.Price).toFixed(2);
        this.camposFormularioPropostaCliente.valorVeiculo = this.ativo.Price - event.target.value;
    }
    
    handleDescontoPorcentagemChange(event) {
        this.camposFormularioPropostaCliente.descontoPorcentagemInput = event.target.value;
        this.camposFormularioPropostaCliente.descontoValorInput = event.target.value == 0 || this.ativo.Price  == 0 ? 0 : (event.target.value * this.ativo.Price)/100;
        this.camposFormularioPropostaCliente.valorVeiculo = this.ativo.Price - (event.target.value == 0 || this.ativo.Price  == 0 ? 0 : (event.target.value * this.ativo.Price)/100);
    }

    adicionarAgregado(event) {
        if (validaContemAgregado(this.camposFormularioPropostaCliente.agregadosCotacao, event.detail.agregadoId)
            || validaContemAgregado(this.camposFormularioPropostaCliente.agregadosAtivo, event.detail.agregadoId)) {
            this.notificationError('Este agregado já foi adicionado!');
        } else {
            this.camposFormularioPropostaCliente.agregadosCotacao.push(event.detail);
            this.valorProposta(this.ativo.Price, this.camposFormularioPropostaCliente.descontoValor);
        }
    }

    clickNewAgregado() {
        const modal = this.template.querySelector('c-modal-adicionar-agregado');
        if (this.itemCotacao) {
            modal.showHide(this.itemCotacao.Id);
        } else {
            modal.showHide(this.itemCotacao);
        }
    }

    removeAgregado(event) {
        this.camposFormularioPropostaCliente.agregadosCotacao = removeDadoAgragadoCotacao(this.camposFormularioPropostaCliente.agregadosCotacao, event.detail.agregadoId);
    }

    handleAnaliseValoresPropostaCliente() {
        this.valorProposta(this.ativo.Price, this.camposFormularioPropostaCliente.descontoValorInput);
    }

    valorProposta(valor, descontoReais) {
        let valorVeiculo = valor && valor != 0 ? valor - descontoReais : 0;
        this.camposFormularioPropostaCliente.precoPublico = valorVeiculo;
        this.camposFormularioPropostaCliente.valorVeiculo = valorVeiculo;
        this.camposFormularioPropostaCliente.custoOperacional.custoOperacao = valor && this.porcentagemCustoOperacional ? valor * this.porcentagemCustoOperacional / 100 : 0;
        this.camposFormularioPropostaCliente.custoOperacional.custoComissao = valor && this.porcentagemComissaoNf ? valor * this.porcentagemComissaoNf / 100 : 0;
        this.camposFormularioPropostaCliente.totalCustoOperacional = this.camposFormularioPropostaCliente.custoOperacional.custoComissao + this.camposFormularioPropostaCliente.custoOperacional.custoOperacao;

        let me = this;
        this.camposFormularioPropostaCliente.totalValorAgregado = 0;
        this.camposFormularioPropostaCliente.valorCustoCliente = 0;
        if (this.camposFormularioPropostaCliente.agregadosAtivo.length > 0) {
            this.camposFormularioPropostaCliente.agregadosAtivo.forEach(function (val, index) {
                me.camposFormularioPropostaCliente.totalValorAgregado = me.camposFormularioPropostaCliente.totalValorAgregado + val.valor;
            })
        }
        if (this.camposFormularioPropostaCliente.agregadosCotacao.length > 0) {
            this.camposFormularioPropostaCliente.agregadosCotacao.forEach(function (val, index) {
                if (val.custoVeiculo) {
                    me.camposFormularioPropostaCliente.totalValorAgregado = me.camposFormularioPropostaCliente.totalValorAgregado + val.valor;
                } else {
                    me.camposFormularioPropostaCliente.valorCustoCliente = me.camposFormularioPropostaCliente.valorCustoCliente + val.valor;

                }
            })
        }
        let lucroFixo = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.custoDireto.veiculo;

        if(this.camposFormularioPropostaCliente.estoqueVeiculo == 'VU'){
            this.camposFormularioPropostaCliente.custoDireto.icmsRetido = lucroFixo && this.camposFormularioPropostaCliente.ICMSVendaAsset ? lucroFixo * this.camposFormularioPropostaCliente.ICMSVendaAsset / 100 : 0;

        }else{
            this.camposFormularioPropostaCliente.custoDireto.icmsRetido = this.camposFormularioPropostaCliente.custoDireto.veiulo && this.camposFormularioPropostaCliente.ICMSVendaAsset ? this.camposFormularioPropostaCliente.custoDireto.veiculo * this.camposFormularioPropostaCliente.ICMSVendaAsset / 100 : 0;
        }
        
        this.camposFormularioPropostaCliente.totalCustoBruto = this.camposFormularioPropostaCliente.totalCustoDireto + this.camposFormularioPropostaCliente.totalValorAgregado;
        this.camposFormularioPropostaCliente.totalCusto = this.camposFormularioPropostaCliente.totalCustoBruto + this.camposFormularioPropostaCliente.totalCustoOperacional;
        this.camposFormularioPropostaCliente.margemBrutaValor = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.totalCustoBruto;
        this.camposFormularioPropostaCliente.margemBruta = this.camposFormularioPropostaCliente.precoPublico == 0 ? 0 : this.camposFormularioPropostaCliente.margemBrutaValor / this.camposFormularioPropostaCliente.precoPublico;
        this.camposFormularioPropostaCliente.margemLiquidaValor = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.totalCusto;
        this.camposFormularioPropostaCliente.margemLiquida = this.camposFormularioPropostaCliente.precoPublico == 0 ? 0 : this.camposFormularioPropostaCliente.margemLiquidaValor / this.camposFormularioPropostaCliente.precoPublico;
        const desconto = valor == 0 ? 0 : descontoReais * 100 / valor;
        const lucro = valorVeiculo == 0 ? 0 : this.camposFormularioPropostaCliente.margemBrutaValor * 100 / valorVeiculo;
        const margem = valorVeiculo == 0 ? 0 : this.camposFormularioPropostaCliente.margemLiquidaValor * 100 / valorVeiculo;
        
        this.camposFormularioPropostaCliente.descontoPorcentagem = this.camposFormularioPropostaCliente.descontoPorcentagemInput;
        this.camposFormularioPropostaCliente.descontoValor = this.camposFormularioPropostaCliente.descontoValorInput;
        
        this.validaDescontoMargemLucro( desconto, lucro, margem);
        this.camposFormularioPropostaCliente.valorTotalComAgregados = Number(valor - descontoReais) + this.camposFormularioPropostaCliente.valorCustoCliente;
        
        let lucroFixo2 = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.custoDireto.veiculo - this.camposFormularioPropostaCliente.custoDireto.icmsRetido;
        this.camposFormularioPropostaCliente.custoDireto.pisCofins = this.camposFormularioPropostaCliente.pisCofinsAsset && lucroFixo2 ? this.camposFormularioPropostaCliente.pisCofinsAsset * lucroFixo2 / 100 : 0;
        
        this.camposFormularioPropostaCliente.totalCustoDireto = this.camposFormularioPropostaCliente.custoDireto.veiculo + this.camposFormularioPropostaCliente.custoDireto.icmsRetido + this.camposFormularioPropostaCliente.custoDireto.pisCofins;
        
        return true;
    }

    validaDescontoMargemLucro(desconto, lucro, margem) {
        if (desconto <= this.desconto) {
            this.descontoLike = 'utility:like'
            this.descontoVariant = 'success';
        } else {
            this.descontoLike = 'utility:dislike'
            this.descontoVariant = 'error';
        }
        if (lucro >= this.lucroBruto) {
            this.lucroBrutoLike = 'utility:like'
            this.lucroBrutoVariant = 'success';
        } else {
            this.lucroBrutoLike = 'utility:dislike'
            this.lucroBrutoVariant = 'error';
        }
        if (margem >= this.margemLiquida) {
            this.margemLiquidaLike = 'utility:like'
            this.margemLiquidaVariant = 'success';
        } else {
            this.margemLiquidaLike = 'utility:dislike'
            this.margemLiquidaVariant = 'error';
        }
    }


    handleRestauraValoresPropostaCliente() {
        this.camposFormularioPropostaCliente.precoPublico = this.ativo.Price;
        this.camposFormularioPropostaCliente.agregadosCotacao = this.agregadosCotacao;

        this.camposFormularioPropostaCliente.custoOperacional.custoOperacao = this.camposFormularioPropostaCliente.precoPublico * this.porcentagemCustoOperacional / 100;
        this.camposFormularioPropostaCliente.custoOperacional.custoComissao = this.camposFormularioPropostaCliente.precoPublico * this.porcentagemComissaoNf / 100;

        this.camposFormularioPropostaCliente.totalCustoOperacional = this.camposFormularioPropostaCliente.custoOperacional.custoComissao + this.camposFormularioPropostaCliente.custoOperacional.custoOperacao;


        this.camposFormularioPropostaCliente.totalCustoDireto = this.camposFormularioPropostaCliente.custoDireto.veiculo + this.camposFormularioPropostaCliente.custoDireto.icmsRetido;

        let me = this;
        this.camposFormularioPropostaCliente.totalValorAgregado = 0;
        this.camposFormularioPropostaCliente.agregadosAtivo.forEach(function (val, index) {
            me.camposFormularioPropostaCliente.totalValorAgregado = me.camposFormularioPropostaCliente.totalValorAgregado + val.valor;
        })

        this.camposFormularioPropostaCliente.totalCustoBruto = this.camposFormularioPropostaCliente.totalCustoDireto + this.camposFormularioPropostaCliente.totalValorAgregado;
        this.camposFormularioPropostaCliente.totalCusto = this.camposFormularioPropostaCliente.totalCustoBruto + this.camposFormularioPropostaCliente.totalCustoOperacional;

        this.camposFormularioPropostaCliente.margemBrutaValor = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.totalCustoBruto;
        this.camposFormularioPropostaCliente.margemBruta = this.camposFormularioPropostaCliente.margemBrutaValor / this.camposFormularioPropostaCliente.precoPublico;

        this.camposFormularioPropostaCliente.margemLiquidaValor = this.camposFormularioPropostaCliente.precoPublico - this.camposFormularioPropostaCliente.totalCusto;
        this.camposFormularioPropostaCliente.margemLiquida = this.camposFormularioPropostaCliente.margemLiquidaValor / this.camposFormularioPropostaCliente.precoPublico;

        this.camposFormularioPropostaCliente.descontoValor = 0;
        this.camposFormularioPropostaCliente.descontoPorcentagem = 0;

        this.camposFormularioPropostaCliente.descontoValorInput = 0;
        this.camposFormularioPropostaCliente.descontoPorcentagemInput = 0;
        
        this.camposFormularioPropostaCliente.valorVeiculo = this.ativo.Price;
    }

    /* Controle das seções */
    @track informacoesUnidadeClass = 'slds-section';

    handleExpandInformacoesUnidade(event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.informacoesUnidadeClass.includes('slds-is-open')) {
            this.informacoesUnidadeClass = 'slds-section';
        } else {
            this.informacoesUnidadeClass = 'slds-section slds-is-open';
        }
    }

    @track tabelaVendaClass = 'slds-section';

    handleExpandTabelaVenda(event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.tabelaVendaClass.includes('slds-is-open')) {
            this.tabelaVendaClass = 'slds-section';
        } else {
            this.tabelaVendaClass = 'slds-section slds-is-open';
        }
    }

    @track custoGeralVeiculoTabelaVendaClass = false;

    handleExpandcustoGeralVeiculoTabelaVenda(event) {
        event.preventDefault();
        event.stopPropagation();

        if (this.custoGeralVeiculoTabelaVendaClass) {
            this.custoGeralVeiculoTabelaVendaClass = false;
        } else {
            this.custoGeralVeiculoTabelaVendaClass = true;
        }

    }


    @track agregadosExpandClass = 'slds-section slds-is-open';

    handleExpandAgregadosExpandExpand(event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.agregadosExpandClass.includes('slds-is-open')) {
            this.agregadosExpandClass = 'slds-section';
        } else {
            this.agregadosExpandClass = 'slds-section slds-is-open';
        }
    }
    
    @track prospotaClienteExpandClass = 'slds-section slds-is-open';

    handleExpandprospotaClienteExpand(event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.prospotaClienteExpandClass.includes('slds-is-open')) {
            this.prospotaClienteExpandClass = 'slds-section';
        } else {
            this.prospotaClienteExpandClass = 'slds-section slds-is-open';
        }
    }

    @track custoGeralVeiculoPropostaClienteClass = false;

    handleExpandcustoGeralVeiculoPropostaCliente(event) {
        event.preventDefault();
        event.stopPropagation();

        if (this.custoGeralVeiculoPropostaClienteClass) {
            this.custoGeralVeiculoPropostaClienteClass = false;
        } else {
            this.custoGeralVeiculoPropostaClienteClass = true;
        }

    }

    onCancelar() {
        this.handleRestauraValoresPropostaCliente();
        this.navigateToRecordViewPage(this.recordId, this.objectApiName);
    }

    onSalvar() {
        const allValid = this.valorProposta(this.ativo.Price, this.camposFormularioPropostaCliente.descontoValorInput);
        this.disabledBtn = true;
        this.salvarOn = true;
        this.cancelarOn = true;
        if (allValid) {
            this.salvar(JSON.stringify(
                {
                    precoPublico: this.camposFormularioPropostaCliente.precoPublico,
                    valorTotalComAgregados: this.camposFormularioPropostaCliente.valorTotalComAgregados,
                    agregadosCotacao: this.camposFormularioPropostaCliente.agregadosCotacao                    
                }
            ), this.recordId);
        }
    }

    onVoltar() {
        this.handleRestauraValoresPropostaCliente()
        this.dispatchEvent(new CustomEvent('backestoque', {}));
    }

    salvar(dados, recordId) {
        salvarSimulacao({ dadosSimilacaoJson: dados , recordId: recordId})
            .then(result => {
                this.notificationSuccess('Sua simulação foi salva com sucesso!');
                this.disabledBtn = false;
            })
            .then(result => {
                this.init = true;
                this.initCustos = true;
                this.initAsset = true;
            })
            .catch(error => {
                this.disabledBtn = false;
                this.salvarOn = false;
                this.cancelarOn = false;
                console.error(JSON.stringify(error));
                this.notificationError(error.body.message);
            });
    }

    // Toast de erro
    notificationError(mensagem) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erro!',
                message: mensagem,
                variant: 'error',
            }),
        );
    }

    notificationSuccess(mensagem) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sucesso',
                message: mensagem,
                variant: 'success',
            }),
        );
    }

    notificationWarning(mensagem) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Aviso!',
                message: mensagem,
                variant: 'warning',
            }),
        );
    }

    navigateToRecordViewPage(recordId, objectName) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectName, // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}