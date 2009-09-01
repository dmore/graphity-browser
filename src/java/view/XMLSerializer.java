/*
 * FormXMLSerializer.java
 *
 * Created on Še�?tadienis, 2007, Kovo 10, 15.41
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package view;

import frontend.controller.form.ScatterChartForm;
import java.io.StringWriter;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 *
 * @author Pumba
 */
public class XMLSerializer
{

    private static DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    private static DocumentBuilder builder = null;
    private static Transformer transformer = null;

    private static void init() throws ParserConfigurationException, TransformerConfigurationException
    {
	if (builder == null) builder = factory.newDocumentBuilder();
	if (transformer == null) transformer = TransformerFactory.newInstance().newTransformer();
	
	transformer.setOutputProperty(OutputKeys.INDENT, "yes");
    }

    public static String serialize(Document document) throws TransformerConfigurationException, TransformerException, ParserConfigurationException
    {
	XMLSerializer.init();

	//initialize StreamResult with File object to save to file
	StreamResult result = new StreamResult(new StringWriter());
	DOMSource source = new DOMSource(document);

	transformer.transform(source, result);

	//System.out.println(result.getWriter().toString());

	return result.getWriter().toString();
    }

    public static String serialize(ScatterChartForm form) throws ParserConfigurationException, TransformerConfigurationException, TransformerException
    {
	XMLSerializer.init();

	Document document = builder.newDocument();

	Element formElem = document.createElement(form.getClass().getSimpleName());
	document.appendChild(formElem);

	if (form.getXBinding() != null)
	{
	    Element xBindingElem = document.createElement("XBinding");
	    xBindingElem.appendChild(document.createTextNode(form.getXBinding()));
	    formElem.appendChild(xBindingElem);
	}
	if (form.getYBinding() != null)
	{
	    Element yBindingElem = document.createElement("YBinding");
	    for (String yBinding : form.getYBinding())
		yBindingElem.appendChild(document.createTextNode(yBinding));
	    formElem.appendChild(yBindingElem);
	}
	
	return serialize(document);
    }

}
